module Publish
  module Providers
    module Schools
      class RemoveCoursesController < ApplicationController
        helper_method :provider
        before_action :set_recruitment_cycle
        before_action :set_school
        before_action :set_course

        def show; end

        def destroy
          @school.courses.delete(@course)
          @school.reload

          redirect_to publish_provider_recruitment_cycle_school_path(
            provider.provider_code,
            @recruitment_cycle.year,
            @school.id,
          ),
                      flash: { success: "#{@course.name_and_code} removed from #{@school.location_name}" }
        end

      private

        def set_recruitment_cycle
          @recruitment_cycle = RecruitmentCycle.find_by!(
            year: params[:recruitment_cycle_year],
          )
        end

        def set_school
          @school = Site.find(params[:id])
        end

        def set_course
          @course = Course.find_by!(course_code: params[:course_code])
        end
      end
    end
  end
end
