# frozen_string_literal: true

module Publish
  module Courses
    class InterviewProcessController < PublishController
      include CopyCourseContent
      before_action :authorise_with_pundit

      def edit
        @interview_process_form = CourseInterviewProcessForm.new(course_enrichment)
        @copied_fields = copy_content_check(::Courses::Copy::INTERVIEW_PROCESS_FIELDS)

        @copied_fields_values = copied_fields_values if @copied_fields.present?

        @interview_process_form.valid? if show_errors_on_publish?
      end

      def update
        @interview_process_form = CourseInterviewProcessForm.new(course_enrichment, params: interview_process_params)

        if @interview_process_form.save!
          course_updated_message I18n.t('publish.providers.interview_process.edit.interview_process_success')

          redirect_to redirect_path
        else
          fetch_course_list_to_copy_from
          render :edit
        end
      end

      private

      def authorise_with_pundit
        authorize course_to_authorise
      end

      def interview_process_params
        params.require(:publish_course_interview_process_form).permit(*CourseInterviewProcessForm::FIELDS)
      end

      def course_to_authorise
        @course_to_authorise ||= provider.courses.find_by!(course_code: params[:code])
      end

      def course
        @course ||= CourseDecorator.new(course_to_authorise)
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def redirect_path
        publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code
        )
      end
    end
  end
end
