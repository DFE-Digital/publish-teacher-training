module API
  module V2
    module AccreditedBody
      class CoursesController < API::V2::ApplicationController
        before_action :build_recruitment_cycle
        before_action :build_provider

        def index
          authorize @provider, :can_list_courses?
          render jsonapi: @provider.current_accredited_courses, include: params[:include], class: CourseSerializersService.new.execute
        end

      private

        def build_provider
          @provider = @recruitment_cycle.providers.find_by!(
            provider_code: params[:provider_code].upcase,
            )
        end

        def build_recruitment_cycle
          @recruitment_cycle = RecruitmentCycle.find_by(
            year: params[:recruitment_cycle_year],
            ) || RecruitmentCycle.current_recruitment_cycle
        end
      end
    end
  end
end
