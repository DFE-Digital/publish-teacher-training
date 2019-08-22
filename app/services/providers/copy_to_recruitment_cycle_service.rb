module Providers
  class CopyToRecruitmentCycleService
    def initialize(provider:)
      @provider = provider
    end

    def execute(new_recruitment_cycle)
      providers_count = 0
      sites_count = 0
      courses_count = 0

      ActiveRecord::Base.transaction do
        new_provider = new_recruitment_cycle
                          .providers
                          .find_by(provider_code: @provider.provider_code)

        unless new_provider
          providers_count = 1
          new_provider = @provider.dup
          new_provider.organisations << @provider.organisations
          new_provider.ucas_preferences = @provider.ucas_preferences.dup
          new_provider.contacts << @provider.contacts.map(&:dup)
          new_provider.recruitment_cycle = new_recruitment_cycle

          new_provider.save!
        end

        # Order is important here. Sites should be copied over before courses
        # so that courses can link up to the correct sites in the new provider.
        sites_count = copy_sites_to_new_provider(new_provider)
        courses_count = copy_courses_to_new_provider(new_provider)
      end

      {
        providers: providers_count,
        sites: sites_count,
        courses: courses_count
      }
    end

  private

    def copy_courses_to_new_provider(new_provider)
      courses_count = 0

      @provider.courses.each do |course|
        new_course = Courses::CopyToProviderService.new(course: course).execute(new_provider)
        courses_count += 1 if new_course.present?
      end

      courses_count
    end

    def copy_sites_to_new_provider(new_provider)
      sites_count = 0

      @provider.sites.each do |site|
        sites_count += 1 if site.copy_to_provider(new_provider)
      end

      sites_count
    end
  end
end
