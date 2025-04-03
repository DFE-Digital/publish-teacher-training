# frozen_string_literal: true

module API
  module Public
    module V1
      class CoursesController < API::Public::V1::ApplicationController
        def index
          render jsonapi: paginate(courses),
                 include: include_param,
                 meta: { count: cached_course_count },
                 class: API::Public::V1::SerializerService.call
        rescue ActiveRecord::StatementInvalid
          render json: { status: 400, message: "Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`" }.to_json, status: :bad_request
        end

      private

        def cached_course_count
          year = permitted_params[:recruitment_cycle_year] || RecruitmentCycle.current.year

          Rails.cache.fetch("api_course_count_#{year}", expires_in: 5.minutes) do
            courses.count("course.id")
          end
        end

        def courses
          @courses ||= APICourseSearchService.call(
            filter: permitted_params[:filter],
            sort: permitted_params[:sort],
            course_scope: recruitment_cycle.courses,
          )
        end

        def include_param
          permitted_params.fetch(:include, "")
        end

        def permitted_params
          params.permit("page", "sort", "per_page", "courses", "recruitment_cycle_year", "include", "filter" => %w[updated_since funding_type])
        end
      end
    end
  end
end
