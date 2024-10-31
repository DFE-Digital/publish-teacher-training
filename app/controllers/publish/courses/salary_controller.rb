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

        if @course_salary_form.save!
          course_updated_message I18n.t('publish.providers.course_salary.edit.course_salary')

          redirect_to publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )
        else
          render :edit
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
