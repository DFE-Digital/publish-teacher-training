# frozen_string_literal: true

module Publish
  module Courses
    class SalaryController < BaseFundingTypeController
      def edit
        @course_salary_form = CourseSalaryForm.new(course_enrichment)
        @course_salary_form.valid? if show_errors_on_publish?
      end

      def update
        @course_salary_form = CourseSalaryForm.new(course_enrichment, params: formatted_params)
        section_name = I18n.t("publish.providers.course_salary.edit.course_salary")

        if @course_salary_form.invalid?
          render :edit
        elsif confirm_live_changes_if_required!(
          section_name:,
          form: @course_salary_form,
          form_param_key: funding_type,
        )
          # rendered interstitial
        elsif @course_salary_form.save!
          course_updated_message section_name

          redirect_to publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        end
      end

    private

      def funding_type
        :publish_course_salary_form
      end

      def funding_type_fields
        CourseSalaryForm::FIELDS
      end
    end
  end
end
