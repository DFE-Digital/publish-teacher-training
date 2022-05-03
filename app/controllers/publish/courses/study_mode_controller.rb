module Publish
  module Courses
    class StudyModeController < PublishController
      include CourseBasicDetailConcern

      def edit
        authorize(provider)

        @course_study_mode_form = CourseStudyModeForm.new(@course)
      end

      def update
        authorize(provider)

        @course_study_mode_form = CourseStudyModeForm.new(@course, params: study_mode_params)
        if @course_study_mode_form.save!
          course_description_success_message("full or part time")

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      end

    private

      def study_mode_params
        return { study_mode: nil } if params[:publish_course_study_mode_form].blank?

        params.require(:publish_course_study_mode_form).permit(*CourseStudyModeForm::FIELDS)
      end

      def current_step
        :full_or_part_time
      end

      def errors
        params.dig(:course, :study_mode) ? {} : { study_mode: ["Pick full time, part time or full time and part time"] }
      end
    end
  end
end
