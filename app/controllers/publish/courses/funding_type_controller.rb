# frozen_string_literal: true

module Publish
  module Courses
    class FundingTypeController < ApplicationController
      include CourseBasicDetailConcern

      def edit
        authorize(course, :can_update_funding_type?)
        @course_funding_form = CourseFundingForm.new(@course)
        @course_funding_form.clear_stash
      end

      def update
        authorize(course, :can_update_funding_type?)

        @course_funding_form = CourseFundingForm.new(@course, params: funding_type_params)

        if @course_funding_form.invalid?
          handle_invalid_form
        elsif !previous_tda_course? && confirm_live_changes_if_required!(
          section_name: "Funding type",
          form: @course_funding_form,
          form_param_key: :publish_course_funding_form,
          fields: %i[funding previous_tda_course],
          cancel_path: details_publish_provider_recruitment_cycle_course_path(
            course.provider_code, course.recruitment_cycle_year, course.course_code
          ),
        )
          # rendered interstitial
        else
          handle_valid_form
        end
      end

    private

      def funding_type_params
        return {} if params[:publish_course_funding_form].blank?

        params.expect(publish_course_funding_form: %i[funding previous_tda_course])
      end

      def handle_valid_form
        if previous_tda_course?
          process_previous_tda_course
        else
          redirect_to next_path
        end
      end

      def handle_invalid_form
        @errors = @course_funding_form.errors.messages
        render :edit
      end

      def previous_tda_course?
        params.dig(:publish_course_funding_form, :previous_tda_course) == "true"
      end

      def process_previous_tda_course
        @course_funding_form.save! if @course_funding_form.funding_updated?
        redirect_to full_part_time_publish_provider_recruitment_cycle_course_path(
          provider_code: course.provider_code,
          recruitment_cycle_year: course.recruitment_cycle_year,
          course_code: course.course_code,
          previous_tda_course: true,
        )
      end

      def next_path
        if @course_funding_form.funding_updated?
          @course_funding_form.stash
          visa_page_path
        else
          flash[:success] = t(".updated")
          course_page_path
        end
      end

      def course_values
        {
          provider_code: course.provider_code,
          recruitment_cycle_year: course.recruitment_cycle_year,
          course_code: course.course_code,
        }
      end

      def visa_page_path
        if @course_funding_form.student_visa?
          student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(course_values)
        else
          skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(course_values)
        end
      end

      def course_page_path
        details_publish_provider_recruitment_cycle_course_path(course_values)
      end
    end
  end
end
