require 'dry/container'

class ServiceContainer
  def initialize
    @services = Dry::Container.new
    register_services
  end

  def define(namespace, name, &block)
    @services.namespace(namespace) do
      register(name, block)
    end
  end

  def get(namespace, service_name)
    @services.resolve("#{namespace}.#{service_name}")
  end

private

  def register_services
    Courses::RegisterServices.execute(self)

    define(:sites, :copy_to_course) do
      Sites::CopyToCourseService.new
    end

    define(:sites, :copy_to_provider) do
      Sites::CopyToProviderService.new
    end

    define(:enrichments, :copy_to_course) do
      Enrichments::CopyToCourseService.new
    end

    define(:providers, :copy_to_recruitment_cycle) do
      Providers::CopyToRecruitmentCycleService.new(
        copy_course_to_provider_service: get(:courses, :copy_to_provider),
        copy_site_to_provider_service: get(:sites, :copy_to_provider),
      )
    end
  end
end
