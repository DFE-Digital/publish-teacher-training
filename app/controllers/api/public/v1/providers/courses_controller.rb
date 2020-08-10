module API
  module Public
    module V1
      module Providers
        class CoursesController < API::Public::V1::ApplicationController
          PERMITTED_INCLUSIONS = %w[provider].freeze
          PERMITTED_SORTS = ["name", "-name"].freeze

          def index
            render jsonapi: paginate(courses),
              fields: fields_param,
              include: include_param,
              class: API::Public::V1::SerializerService.new.execute
          end

          def show
            render jsonapi: course,
              class: API::Public::V1::SerializerService.new.execute
          end

        private

          def course
            @course ||= provider.courses.find_by!(course_code: params[:code])
          end

          def courses
            return @courses if @courses

            search_service = API::Public::V1::CourseSearchService.new(
              base_scope: provider.courses,
              filter: filter,
              sort: sort_param,
                                              )

            @courses = search_service.call
          end

          def filter
            @filter ||= params[:filter] || {}
          end

          def provider
            @provider ||= recruitment_cycle.providers.find_by!(provider_code: params[:provider_code])
          end

          def recruitment_cycle
            @recruitment_cycle ||= RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
          end

          def include_param
            (params.fetch(:include, "")
              .split(",") & PERMITTED_INCLUSIONS)
              .join(",")
          end

          def sort_param
            @sort_param ||= Set.new(params.dig(:sort)&.split(",")) & PERMITTED_SORTS
          end
        end
      end
    end
  end
end
