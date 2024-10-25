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
          render json: { status: 400, message: 'Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`' }.to_json, status: :bad_request
        end

        private

        def cached_course_count
          if params[:no_cache]
            courses.count('course.id')
          else
            Rails.cache.fetch('api_course_count', expires_in: 5.minutes) do
              courses.count('course.id')
            end
          end
        end

        def courses
          @courses ||= APICourseSearchService.call(
            filter: params[:filter],
            sort: params[:sort],
            course_scope: recruitment_cycle.courses
          )
        end

        def include_param
          params.fetch(:include, '')
        end
      end
    end
  end
end
