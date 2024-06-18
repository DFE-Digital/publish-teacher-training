# frozen_string_literal: true

module Publish
  module Courses
    class FeesAndFinancialSupportController < PublishController
      include CopyCourseContent
      before_action :authorise_with_pundit

      def edit
        @course_fees_and_financial_support_form = CourseFeesAndFinancialSupportForm.new(course_enrichment)
        @copied_fields = copy_content_check(::Courses::Copy::FEES_FINANCIAL_SUPPORT_FIELDS)

        @copied_fields_values = copied_fields_values if @copied_fields.present?
        @course_fees_and_financial_support_form.valid? if show_errors_on_publish?
      end

      def update
        @course_fees_and_financial_support_form = CourseFeesAndFinancialSupportForm.new(
          course_enrichment,
          params: fees_and_financial_support_params
        )

        if @course_fees_and_financial_support_form.save!
          course_updated_message CourseEnrichment.human_attribute_name('fee_details')

          redirect_to publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )

        else
          fetch_course_list_to_copy_from
          render :edit
        end
      end

      private

      def fees_and_financial_support_params
        params
          .require(:publish_course_fees_and_financial_support_form)
          .permit(*CourseFeesAndFinancialSupportForm::FIELDS)
      end

      def authorise_with_pundit
        authorize course_to_authorise
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
    end
  end
end
