# frozen_string_literal: true

module Publish
  module Courses
    class SalaryFeesController < ApplicationController
      include CopyCourseContent
      include GotoPreview

      before_action :previous_cycle_enrichment, only: :edit

      def edit
        @course_salary_fees_form = ::Publish::CourseSalaryFeesForm.new(course_enrichment)
        @course_salary_fees_form.valid? if show_errors_on_publish?
        @copied_fields = copy_content_check(::Courses::Copy::SALARY_FEES_FIELDS)
        @copied_fields_values = copied_fields_values if @copied_fields.present?
      end

      def update
        @course_salary_fees_form = ::Publish::CourseSalaryFeesForm.new(course_enrichment, params: form_params)
        section_name = t(".course_salary_fee")

        if @course_salary_fees_form.invalid?
          fetch_course_list_to_copy_from
          render :edit
        elsif confirm_live_changes_if_required!(
          section_name:,
          form: @course_salary_fees_form,
          form_param_key:,
        )
          # rendered interstitial
        elsif @course_salary_fees_form.save!
          course_updated_message section_name

          if goto_preview?
            redirect_to preview_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )
          else
            redirect_to publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )
          end
        end
      end

    private

      def form_params
        params.require(:publish_course_salary_fees_form).permit(:salary_fee_details)
      end

      def course
        @course ||= provider.courses.find_by!(course_code: params[:code])
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end

      def previous_cycle_enrichment
        @previous_cycle_enrichment ||= course.recruitment_cycle.previous&.providers&.find_by(
          provider_code: @provider.provider_code,
        )&.courses&.find_by(
          course_code: course.course_code,
        )&.enrichments&.where(
          status: "published",
        )&.last
      end

      def param_form_key
        :publish_course_salary_fees_form
      end
    end
  end
end
