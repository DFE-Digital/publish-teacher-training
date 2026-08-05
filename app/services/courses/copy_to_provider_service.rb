# frozen_string_literal: true

module Courses
  class CopyToProviderService
    attr_reader :courses_copied, :courses_not_copied

    def initialize(schools_copy_to_course:, sites_copy_to_course:, enrichments_copy_to_course:, force:)
      @schools_copy_to_course = schools_copy_to_course
      @sites_copy_to_course = sites_copy_to_course
      @enrichments_copy_to_course = enrichments_copy_to_course
      @force = force
      @courses_copied = []
      @courses_not_copied = []
    end

    def execute(course:, new_provider:)
      @courses_not_copied << course and return unless course.rollable? || force

      @courses_not_copied << course and return if course_code_already_exists_on_provider?(course:, new_provider:)

      new_course = nil

      Course.transaction do
        new_course                                          = course.dup
        new_course.uuid                                     = nil
        new_course.application_status                       = "closed"
        new_course.provider                                 = new_provider
        year_differential                                   = new_course.recruitment_cycle.year.to_i - course.recruitment_cycle.year.to_i
        new_course.applications_open_from                   = adjusted_applications_open_from_date(course:, new_provider:, year_differential:)
        new_course.start_date                               = course.start_date + year_differential.year
        course.course_subjects.each do |cs|
          new_course.course_subjects.build(subject_id: cs.subject_id, position: cs.position)
        end
        new_course.can_sponsor_skilled_worker_visa          = course.can_sponsor_skilled_worker_visa
        new_course.can_sponsor_student_visa                 = course.can_sponsor_student_visa
        new_course.publish_without_schools_allowed          = course.publish_without_schools_allowed
        new_course.visa_sponsorship_application_deadline_at = nil # We can't currently predict how to carry this value over. Provider must set it again
        new_course.first_published_at                       = nil
        new_course.save!(validate: false)

        copy_latest_enrichment_to_course(course, new_course)

        copy_schools(course:, new_provider:, new_course:)
        copy_study_sites(course:, new_provider:, new_course:)
      end
      new_course.tap { @courses_copied << it }
    end

  private

    attr_reader :schools_copy_to_course, :sites_copy_to_course, :enrichments_copy_to_course, :force

    def course_code_already_exists_on_provider?(course:, new_provider:)
      new_provider.courses.with_discarded.where(course_code: course.course_code).any?
    end

    def copy_latest_enrichment_to_course(course, new_course)
      latest_enrichment = if course.enrichments.blank?
                            enrichment = CourseEnrichment.new(course:, status: "draft")
                            course.enrichments << enrichment
                            enrichment
                          else
                            course.latest_enrichment
                          end

      @enrichments_copy_to_course.execute(enrichment: latest_enrichment, new_course:)
    end

    def adjusted_applications_open_from_date(course:, new_provider:, year_differential:)
      source_recruitment_cycle = course.recruitment_cycle
      target_recruitment_cycle = new_provider.recruitment_cycle

      return target_recruitment_cycle.application_start_date if course.applications_open_from.blank?

      source_date_range = source_recruitment_cycle.application_start_date..source_recruitment_cycle.application_end_date
      return target_recruitment_cycle.application_start_date unless source_date_range.cover?(course.applications_open_from)

      adjusted_date = if course.applications_open_from == source_recruitment_cycle.application_start_date
                        target_recruitment_cycle.application_start_date
                      else
                        course.applications_open_from + year_differential.year
                      end

      adjusted_date.clamp(target_recruitment_cycle.application_start_date, target_recruitment_cycle.application_end_date)
    end

    def copy_schools(course:, new_provider:, new_course:)
      schools_copy_to_course.call(course:, new_provider:, new_course:)
    end

    def copy_study_sites(course:, new_provider:, new_course:)
      lookup = new_provider_study_sites(new_provider)

      course.study_sites.each do |site|
        new_site = lookup[site.code]

        @sites_copy_to_course.call(new_site:, new_course:) if new_site.present?
      end
    end

    # Every study site belonging to the new provider is created before any
    # course is copied, so load them once per provider rather than per course.
    def new_provider_study_sites(new_provider)
      @new_provider_study_sites ||= {}
      @new_provider_study_sites[new_provider.id] ||= new_provider.study_sites.index_by(&:code)
    end
  end
end
