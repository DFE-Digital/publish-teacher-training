# frozen_string_literal: true

module Publish
  module Courses
    class VisaSponsorshipApplicationDeadlineRequiredController < ApplicationController
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        @deadline_required_form = VisaSponsorshipApplicationDeadlineRequiredForm.new(date_required_params)
      end

      def current_step
        :visa_sponsorship_application_deadline_required
      end

      def date_required_params
        course_params.permit(:visa_sponsorship_application_deadline_required)
      end

      def errors
        @deadline_required_form = VisaSponsorshipApplicationDeadlineRequiredForm.new(date_required_params)
        @deadline_required_form.validate
        @deadline_required_form.errors.messages
      end
    end
  end
end
