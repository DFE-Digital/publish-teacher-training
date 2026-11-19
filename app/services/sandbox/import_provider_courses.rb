# frozen_string_literal: true

module Sandbox
  # Copies a provider's courses for a cycle from production (through the
  # public Publish API) into this environment, keeping production's course
  # and site codes so providers can test their integrations against them.
  #
  # Courses are created or updated and published; nothing is deleted. Unless
  # confirmed, everything is rolled back and only the report is printed.
  class ImportProviderCourses
    include ServicePattern

    Abort = Class.new(StandardError)

    # Errors that mean production's data doesn't fit this course here.
    COURSE_ERRORS = [ActiveRecord::RecordInvalid, ArgumentError, KeyError, Date::Error].freeze

    def initialize(provider_code:, year:, confirm: false, client: PublishPublicAPI::Client.new, out: $stdout)
      @provider_code = provider_code
      @year = year
      @confirm = confirm
      @client = client
      @out = out
      @report = ImportReport.new
    end

    def call
      raise Abort, "Can only be run in sandbox or development" unless Rails.env.sandbox? || Rails.env.local?

      provider = find_provider
      prod_courses = fetch_prod_courses

      ActiveRecord::Base.transaction do
        prod_courses.each { |prod_course, locations| import_course(provider, prod_course, locations) }
        @report.sandbox_only = provider.courses.where.not(course_code: prod_courses.map { |c, _| c.dig("attributes", "code") }).pluck(:course_code)

        raise ActiveRecord::Rollback unless @confirm
      end

      report
      @report
    end

  private

    def find_provider
      recruitment_cycle = RecruitmentCycle.find_by(year: @year)
      raise Abort, "There is no #{@year} recruitment cycle here" if recruitment_cycle.nil?

      provider = recruitment_cycle.providers.find_by(provider_code: @provider_code)
      raise Abort, "Provider #{@provider_code} isn't in the #{@year} recruitment cycle here" if provider.nil?

      provider
    end

    # Fetched before the transaction opens, so no transaction waits on the API.
    def fetch_prod_courses
      @client.courses(year: @year, provider_code: @provider_code).map do |prod_course|
        course_code = prod_course.dig("attributes", "code")
        [prod_course, @client.course_locations(year: @year, provider_code: @provider_code, course_code:)]
      end
    end

    def import_course(provider, prod_course, locations)
      mapper = CourseAttributesMapper.new(prod_course["attributes"])
      course_report = ImportReport.new

      # A savepoint per course, so one that fails leaves nothing half-written.
      Course.transaction(requires_new: true) do
        subjects = find_subjects(mapper)
        unknown_codes = mapper.subject_codes - subjects.map(&:subject_code)
        return skip(mapper, "unknown subject codes #{unknown_codes.join(', ')}") if unknown_codes.any?

        # with_discarded: course codes are unique per provider, deleted courses included.
        course = Course.with_discarded.find_or_initialize_by(provider:, course_code: mapper.course_code)
        created = course.new_record?
        restored = course.discarded?

        save_course(course, mapper, subjects, course_report)
        ImportCourseSchools.call(course:, locations:, report: course_report)
        missing_accredited_provider = add_partnership(provider, course, course_report)

        reasons = []
        reasons << "school conflict" if course_report.conflicts.any?
        reasons << "accredited provider #{missing_accredited_provider} missing" if missing_accredited_provider
        course_report.not_published << "#{course.course_code}: #{reasons.join(', ')}" if reasons.any?

        save_enrichment(course, mapper, publish: reasons.empty?)

        if created
          course_report.created << course.course_code
        else
          course_report.updated << (restored ? "#{course.course_code} (restored)" : course.course_code)
        end
      end

      # Only once the course's savepoint has been released.
      @report.merge!(course_report)
    rescue *COURSE_ERRORS => e
      skip(mapper, e.message)
    end

    def find_subjects(mapper)
      subjects = Subject.where(subject_code: mapper.subject_codes).index_by(&:subject_code)
      subjects = mapper.subject_codes.filter_map { |code| subjects[code] }
      return subjects if subjects.size != mapper.subject_codes.size

      with_modern_languages(subjects)
    end

    # The Modern Languages subject has no code, so the API leaves it out, but a
    # course with languages needs it (Course#validate_modern_languages).
    def with_modern_languages(subjects)
      return subjects unless subjects.any?(ModernLanguagesSubject)

      [SecondarySubject.modern_languages, *subjects].uniq
    end

    def save_course(course, mapper, subjects, course_report)
      if course.new_record?
        course.uuid = ProductionUuid.keep(mapper.uuid, unless_used_by: Course.with_discarded, label: mapper.course_code, report: course_report)
      end
      course.assign_attributes(mapper.course_attributes)
      course.discarded_at = nil

      if course.course_subjects.map(&:subject_id) != subjects.map(&:id)
        course.course_subjects.destroy_all if course.persisted?
        course.course_subjects.reset
        subjects.each_with_index { |subject, position| course.course_subjects.build(subject:, position:) }
      end

      Courses::AssignSubjectsService.assign_master_and_subordinate_subjects(course, subjects.map(&:id))

      course.save!
    end

    # Publishes by marking the enrichment published directly: Courses::PublishService
    # would email subscribers and checks fields the public API doesn't expose.
    #
    # A course that didn't import cleanly isn't published: production's content
    # goes into a draft, leaving any published content here as it was.
    def save_enrichment(course, mapper, publish:)
      enrichments = course.enrichments
      enrichment = if publish
                     enrichments.find_or_initialize_draft
                   else
                     enrichments.select(&:draft?).last || enrichments.build(enrichments.new_draft_attributes)
                   end

      enrichment.assign_attributes(mapper.enrichment_attributes)
      enrichment.version = mapper.enrichment_version

      if publish
        enrichment.status = :published
        enrichment.last_published_timestamp_utc ||= Time.zone.now
      end
      enrichment.save!

      course.update!(first_published_at: Time.zone.now) if publish && course.first_published_at.blank?
    end

    # Returns the accredited provider's code when it isn't here.
    def add_partnership(provider, course, course_report)
      code = course.accredited_provider_code
      return if code.blank? || code == provider.provider_code

      accredited_provider = provider.recruitment_cycle.providers.find_by(provider_code: code)

      if accredited_provider.nil?
        course_report.missing_accredited_providers << code
        return code
      end

      ProviderPartnership.find_or_create_by!(training_provider: provider, accredited_provider:)
      nil
    end

    def skip(mapper, reason)
      @report.skipped << "#{mapper.course_code}: #{reason}"
    end

    def report
      @out.puts "#{@confirm ? 'COMMITTED' : 'DRY RUN - rolled back, run again with confirm to commit'}: #{@provider_code} #{@year}"
      line("Created", "course", @report.created)
      line("Updated", "course", @report.updated)
      line("Skipped", "course", @report.skipped, separator: "\n  ")
      line("Created", "provider school", @report.schools_created)
      line("Created", "GIAS school", @report.gias_stubs)
      line("Unlinked", "school", @report.schools_unlinked)
      line("Conflicting", "school", @report.conflicts, separator: "\n  ")
      line("Generated a new uuid for", "record", @report.uuid_clashes, separator: "\n  ")
      line("Missing", "accredited provider", @report.missing_accredited_providers)
      line("Not published", "course", @report.not_published, separator: "\n  ")
      line("Only in this environment (left alone),", "course", @report.sandbox_only)
    end

    def line(verb, noun, items, separator: ", ")
      return if items.empty?

      @out.puts "#{verb} #{items.size} #{noun.pluralize(items.size)}: #{items.join(separator)}"
    end
  end
end
