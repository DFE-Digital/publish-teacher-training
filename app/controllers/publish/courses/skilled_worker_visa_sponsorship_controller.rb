# frozen_string_literal: true

module Publish
  module Courses
    class SkilledWorkerVisaSponsorshipController < VisaSponsorshipController
      def new
        authorize(@provider, :can_create_course?)
        @course.can_sponsor_skilled_worker_visa = @provider.can_sponsor_skilled_worker_visa unless @course.can_sponsor_skilled_worker_visa
        return if salaried_course?(course)

        redirect_to next_step
      end

      private

      def current_step
        :can_sponsor_skilled_worker_visa
      end

      def error_keys
        [:can_sponsor_skilled_worker_visa]
      end

      def salaried_course?(course)
        course.school_direct_salaried_training_programme? || course.pg_teaching_apprenticeship? || course.scitt_salaried_programme? || course.higher_education_salaried_programme?
      end
    end
  end
end
