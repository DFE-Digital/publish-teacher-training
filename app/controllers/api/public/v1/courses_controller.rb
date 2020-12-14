module API
  module Public
    module V1
      class CoursesController < API::Public::V1::ApplicationController
        def index
          render jsonapi: paginated_records,
                 include: include_param,
                 class: API::Public::V1::SerializerService.call
        end

      private

        def pagy_scope
          @pagy_scope ||= CourseSearchService.call(
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
