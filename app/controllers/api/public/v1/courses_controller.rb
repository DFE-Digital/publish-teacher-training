module API
  module Public
    module V1
      class CoursesController < API::Public::V1::ApplicationController
        def index
          render jsonapi: paginate(courses), include: include_param, class: API::Public::V1::SerializerService.call
        end

      private

        def courses
          @courses ||= recruitment_cycle.courses
        end

        def recruitment_cycle
          @recruitment_cycle ||= RecruitmentCycle.find_by!(year: params[:recruitment_cycle_year])
        end

        def include_param
          params.fetch(:include, "")
        end
      end
    end
  end
end
