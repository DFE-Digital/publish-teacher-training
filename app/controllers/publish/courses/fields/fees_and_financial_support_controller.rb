# frozen_string_literal: true

module Publish
  module Courses
    module Fields
      class FeesAndFinancialSupportController < Publish::Courses::Fields::BaseController
        include CopyCourseContent
        before_action :authorise_with_pundit
        before_action :set_render_fees

        def edit
          @fees_and_financial_support_form = Publish::Fields::FeesAndFinancialSupportForm.new(course_enrichment)
          @copied_fields = copy_content_check(::Courses::Copy::V2_FEES_AND_FINANCIAL_SUPPORT_FIELDS)
          @v1_enrichment = course.enrichments.find_by(version: 1)

          @copied_fields_values = copied_fields_values if @copied_fields.present?
          @fees_and_financial_support_form.valid? if show_errors_on_publish?
        end

        def update
          @fees_and_financial_support_form = Publish::Fields::FeesAndFinancialSupportForm.new(
            course_enrichment,
            params: fees_and_financial_support_params,
          )

          if @fees_and_financial_support_form.save!
            course_updated_message "Fees and financial support"

            redirect_to publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )

          else
            @v1_enrichment = course.enrichments.find_by(version: 1)
            fetch_course_list_to_copy_from
            render :edit
          end
        end

      private

        def set_render_fees
          @render_fees = true
        end

        def fees_and_financial_support_params
          params
            .expect(publish_fields_fees_and_financial_support_form: [*Publish::Fields::FeesAndFinancialSupportForm::FIELDS])
        end
      end
    end
  end
end
