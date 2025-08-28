# frozen_string_literal: true

module Publish
  module Courses
    module Fields
      class InterviewProcessController < Publish::Courses::Fields::BaseController
        include CopyCourseContent
        before_action :authorise_with_pundit

        def edit
          @interview_process_form = Publish::Fields::InterviewProcessForm.new(course_enrichment)
          @copied_fields = copy_content_check(::Courses::Copy::V2_INTERVIEW_PROCESS_FIELDS)

          @copied_fields_values = copied_fields_values if @copied_fields.present?

          @interview_process_form.valid? if show_errors_on_publish?
        end

        def update
          @interview_process_form = Publish::Fields::InterviewProcessForm.new(course_enrichment, params: interview_process_params)

          if @interview_process_form.save!
            course_updated_message I18n.t("publish.providers.interview_process.edit.interview_process_success")

            redirect_to redirect_path
          else
            fetch_course_list_to_copy_from
            render :edit
          end
        end

      private

        def interview_process_params
          params.expect(publish_fields_interview_process_form: [*Publish::Fields::InterviewProcessForm::FIELDS])
        end

        def redirect_path
          publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        end
      end
    end
  end
end
