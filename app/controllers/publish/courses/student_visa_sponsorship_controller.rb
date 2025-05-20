# frozen_string_literal: true

module Publish
  module Courses
    class StudentVisaSponsorshipController < VisaSponsorshipController
      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_student_visa = @provider.can_sponsor_student_visa unless @course.can_sponsor_student_visa
        return if course.fee?

        redirect_to next_step
      end

      def back
        authorize(@provider, :edit?)
        redirect_to new_publish_provider_recruitment_cycle_courses_student_visa_sponsorship_path(path_params)
      end

    private

      def current_step
        :can_sponsor_student_visa
      end

      def error_keys
        [:can_sponsor_student_visa]
      end
    end
  end
end
