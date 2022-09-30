module Publish
  module Courses
    class StudentVisaSponsorshipController < VisaSponsorshipController
      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_student_visa = @provider.can_sponsor_student_visa unless @course.can_sponsor_student_visa
        return if course.is_fee_based?

        redirect_to next_step
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
