module API
  module Public
    module V1
      module Providers
        class CoursesController < API::Public::V1::ApplicationController
          def index
            render jsonapi: paginate(courses),
              include: include_param,
              class: API::Public::V1::SerializerService.new.call
          end

          def show
            render json: {
              data: {
                id: "123",
                type: "Course",
                attributes: {
                  code: "3GTY",
                  provider_code: "6CL",
                  age_minimum: 11,
                  age_maximum: 14,
                },
              },
              jsonapi: {
                version: "1.0",
              },
            }
          end

        private

          def courses
            @courses ||= provider.courses
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
