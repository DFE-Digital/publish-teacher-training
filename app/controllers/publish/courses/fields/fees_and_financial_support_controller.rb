# frozen_string_literal: true

module Publish
  module Courses
    module Fields
      class FeesAndFinancialSupportController < ApplicationController
        include CopyCourseContent
        before_action :authorise_with_pundit

        def edit
          @fees_and_financial_support_form = Publish::Fields::FeesAndFinancialSupportForm.new(course_enrichment)
          @copied_fields = copy_content_check(::Courses::Copy::V2_FEES_AND_FINANCIAL_SUPPORT_FIELDS)

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
            fetch_course_list_to_copy_from
            render :edit
          end
        end

      private

        def fees_and_financial_support_params
          params
            .expect(publish_fields_fees_and_financial_support_form: [*Publish::Fields::FeesAndFinancialSupportForm::FIELDS])
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
end
