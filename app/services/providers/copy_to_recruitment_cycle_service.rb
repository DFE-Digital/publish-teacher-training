module Providers
  class CopyToRecruitmentCycleService
    def initialize(copy_course_to_provider_service:, copy_site_to_provider_service:, force:)
      @copy_course_to_provider_service = copy_course_to_provider_service
      @copy_site_to_provider_service = copy_site_to_provider_service
      @force = force
    end

    def execute(provider:, new_recruitment_cycle:, course_codes: nil)
      providers_count = 0
      sites_count = 0
      courses_count = 0

      if provider.rollable? || force
        ActiveRecord::Base.transaction do
          rolled_over_provider = new_recruitment_cycle.providers.find_by(provider_code: provider.provider_code)
          if rolled_over_provider.nil?
            providers_count = 1
            rolled_over_provider = provider.dup
            rolled_over_provider.organisations << provider.organisations
            rolled_over_provider.ucas_preferences = provider.ucas_preferences.dup
            rolled_over_provider.contacts << provider.contacts.map(&:dup)
            rolled_over_provider.recruitment_cycle = new_recruitment_cycle
            rolled_over_provider.skip_geocoding = true
            rolled_over_provider.users << provider.users
            rolled_over_provider.save!
          end

          # Order is important here. Sites should be copied over before courses
          # so that courses can link up to the correct sites in the new provider.
          sites_count = copy_sites_to_new_provider(provider, rolled_over_provider)
          courses_count = copy_courses_to_new_provider(provider, rolled_over_provider, courses_to_copy(provider, course_codes))
        end
      end

      {
        providers: providers_count,
        sites: sites_count,
        courses: courses_count,
      }
    end

  private

    attr_reader :copy_course_to_provider_service, :copy_site_to_provider_service, :force

    def courses_to_copy(provider, course_codes)
      courses = []
      if force
        if course_codes.nil?
          Rails.logger.info "no courses will be rollover"
        else
          courses = courses_from_course_codes(provider, course_codes)
        end
      elsif course_codes.nil?
        courses = provider.courses
      else
        courses = courses_from_course_codes(provider, course_codes)
      end

      courses
    end

    def courses_from_course_codes(provider, course_codes)
      courses = provider.courses.where(course_code: course_codes.to_a.map(&:upcase))

      if courses.count != course_codes.count
        error_message = "error courses found has discrepancies (#{courses.count} vs #{course_codes.count})"
        Rails.logger.fatal error_message
        raise error_message
      end

      courses
    end

    def copy_courses_to_new_provider(_provider, new_provider, courses)
      courses_count = 0

      courses.each do |course|
        new_course = copy_course_to_provider_service.execute(course: course, new_provider: new_provider)
        courses_count += 1 if new_course.present?
      rescue StandardError
        Rails.logger.fatal "error trying to copy course #{course.course_code}"
        raise
      end

      courses_count
    end

    def copy_sites_to_new_provider(provider, new_provider)
      sites_count = 0

      provider.sites.each do |site|
        new_site = copy_site_to_provider_service.execute(site: site, new_provider: new_provider)
        sites_count += 1 if new_site.present?
      end

      sites_count
    end
  end
end
