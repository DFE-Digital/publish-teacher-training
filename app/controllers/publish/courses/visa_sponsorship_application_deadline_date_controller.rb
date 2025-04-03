# frozen_string_literal: true

module Publish
  module Courses
    class VisaSponsorshipApplicationDeadlineDateController < ApplicationController
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        @deadline_form = Publish::VisaSponsorshipApplicationDeadlineDateForm.build(
          deadline_params,
          recruitment_cycle: @provider.recruitment_cycle,
        )
      end

      def current_step
        :visa_sponsorship_application_deadline_at
      end

      def errors
        @deadline_form = Publish::VisaSponsorshipApplicationDeadlineDateForm.build(
          deadline_params,
          recruitment_cycle: @provider.recruitment_cycle,
        )
        @deadline_form.validate
        @deadline_form.errors.messages
      end

    private

      def deadline_params
        course_params.permit(:visa_sponsorship_application_deadline_at)
      end
    end
  end
end
