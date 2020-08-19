module API
  module Public
    module V1
      module Providers
        module Courses
          class LocationsController < API::Public::V1::ApplicationController
            def index
              render jsonapi: locations,
                     include: include_param,
                     expose: { course: course },
                     class: API::Public::V1::SerializerService.call
            end

          private

            def locations
              @locations ||= course&.sites
            end

            def course
              @course ||= provider.courses.find_by(course_code: params[:course_code])
            end

            def provider
              @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
            end

            def recruitment_cycle
              @recruitment_cycle ||= RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
            end

            def include_param
              params.fetch(:include, "")
            end
          end
        end
      end
    end
  end
end
