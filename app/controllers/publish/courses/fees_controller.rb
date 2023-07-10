# frozen_string_literal: true

module Publish
  module Courses
    class FeesController < BaseFundingTypeController
      include CopyCourseContent
      decorates_assigned :source_course

      def edit
        authorize(provider)

        @course_fee_form = CourseFeeForm.new(course_enrichment)
        @copied_fields = copy_content_check(::Courses::Copy::FEES_FIELDS)

        @copied_fields_values = copied_fields_values if @copied_fields.present?

        @course_fee_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @course_fee_form = CourseFeeForm.new(course_enrichment, params: formatted_params)

        if @course_fee_form.save!
          if goto_preview?
            redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, recruitment_cycle.year, course.course_code)
          else
            course_updated_message('Course length and fees')

            redirect_to publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code
            )
          end

        else
          render :edit
        end
      end

      private

      def funding_type
        :publish_course_fee_form
      end

      def funding_type_fields
        CourseFeeForm::FIELDS
      end
    end
  end
end
