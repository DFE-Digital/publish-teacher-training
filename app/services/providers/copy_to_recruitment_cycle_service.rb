module Providers
  class CopyToRecruitmentCycleService
    def initialize(copy_course_to_provider_service:, copy_site_to_provider_service:)
      @copy_course_to_provider_service = copy_course_to_provider_service
      @copy_site_to_provider_service = copy_site_to_provider_service
    end

    def execute(provider:, new_recruitment_cycle:)
      providers_count = 0
      sites_count = 0
      courses_count = 0

      ActiveRecord::Base.transaction do
        unless provider_code_already_exists_on_recruitment_cycle?(provider, new_recruitment_cycle)
          providers_count = 1
          new_provider = provider.dup
          new_provider.organisations << provider.organisations
          new_provider.ucas_preferences = provider.ucas_preferences.dup
          new_provider.contacts << provider.contacts.map(&:dup)
          new_provider.recruitment_cycle = new_recruitment_cycle

          new_provider.save!
        end

        # Order is important here. Sites should be copied over before courses
        # so that courses can link up to the correct sites in the new provider.
        sites_count = copy_sites_to_new_provider(provider, new_provider)
        courses_count = copy_courses_to_new_provider(provider, new_provider)
      end

      {
        providers: providers_count,
        sites: sites_count,
        courses: courses_count
      }
    end

  private

    def provider_code_already_exists_on_recruitment_cycle?(provider, new_recruitment_cycle)
      new_recruitment_cycle.providers.where(provider_code: provider.provider_code).any?
    end

    def copy_courses_to_new_provider(provider, new_provider)
      courses_count = 0

      provider.courses.each do |course|
        new_course = @copy_course_to_provider_service.execute(course: course, new_provider: new_provider)
        courses_count += 1 if new_course.present?
      end

      courses_count
    end

    def copy_sites_to_new_provider(provider, new_provider)
      sites_count = 0

      provider.sites.each do |site|
        new_site = @copy_site_to_provider_service.execute(site: site, new_provider: new_provider)
        sites_count += 1 if new_site.present?
      end

      sites_count
    end
  end
end
