module API
  module Public
    module V1
      class CoursesController < API::Public::V1::ApplicationController
        def index
          render jsonapi: paginate(courses),
            include: include_param,
            meta: { count: courses.count("course.id") },
            class: API::Public::V1::SerializerService.call
        rescue ActiveRecord::StatementInvalid
          render json: { status: 400, message: "Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`" }.to_json, status: :bad_request
        end

      private

        def courses
          @courses ||= CourseSearchService.call(
            filter: params[:filter],
            sort: params[:sort],
            course_scope: recruitment_cycle.courses,
          )
        end

        def recruitment_cycle
          @recruitment_cycle = RecruitmentCycle.find_by(
            year: params[:recruitment_cycle_year],
          ) || RecruitmentCycle.current_recruitment_cycle
        end

        def include_param
          params.fetch(:include, "")
        end
      end
    end
  end
end
