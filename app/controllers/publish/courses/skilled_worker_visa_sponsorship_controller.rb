module Publish
  module Courses
    class SkilledWorkerVisaSponsorshipController < VisaSponsorshipController
      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_skilled_worker_visa = @provider.can_sponsor_skilled_worker_visa unless @course.can_sponsor_skilled_worker_visa
        return if course.school_direct_salaried_training_programme? || course.pg_teaching_apprenticeship?

        redirect_to next_step
      end

    private

      def current_step
        :can_sponsor_skilled_worker_visa
      end

      def error_keys
        [:can_sponsor_skilled_worker_visa]
      end
    end
  end
end
