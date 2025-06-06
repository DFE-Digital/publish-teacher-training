# frozen_string_literal: true

module Publish
  module Courses
    class VisaSponsorshipController < ApplicationController
      include CourseBasicDetailConcern

      def new
        raise NotImplementedError
      end

      def edit
        visa_sponsorship_form
      end

      def update
        if visa_sponsorship_form.save!
          redirect_to_after_update
        else
          render :edit
        end
      end

    private

      def redirect_to_after_update
        redirect_params = [provider.provider_code, recruitment_cycle.year, course.course_code]
        if course.reload.no_visa_sponsorship?
          flash[:success] = success_message

          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(*redirect_params),
          )
        else
          starting_step = visa_sponsorship_form.origin_step || "visa_sponsorship"
          redirect_to(
            visa_sponsorship_application_deadline_required_publish_provider_recruitment_cycle_course_path(
              *redirect_params,
              starting_step:,
            ),
          )
        end
      end

      def visa_sponsorship_form
        @visa_sponsorship_form ||= CourseFundingForm.new(@course, params: visa_sponsorship_params)
      end

      def current_step
        raise NotImplementedError
      end

      def error_keys
        raise NotImplementedError
      end

      def visa_sponsorship_params
        return {} if params[:publish_course_funding_form].blank?

        params.expect(publish_course_funding_form: CourseFundingForm::FIELDS)
      end

      def success_message
        success_message_key = visa_sponsorship_form.funding_updated? ? "visa_sponsorships.updated.#{visa_sponsorship_form.origin_step}_and_visa" : "visa_sponsorships.updated.visa"

        visa_type = t("visa_sponsorships.#{visa_sponsorship_form.visa_type}")
        t(success_message_key, visa_type:)
      end
    end
  end
end
