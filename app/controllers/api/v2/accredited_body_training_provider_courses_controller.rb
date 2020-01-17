module API
  module V2
    class AccreditedBodyTrainingProviderCoursesController < ApplicationController
      before_action :build_recruitment_cycle, :build_accredited_body, :build_training_provider

      def index
        authorize accredited_body, :can_list_training_providers?

        courses = policy_scope(Course).where(provider_id: training_provider.id)

        render jsonapi: courses, include: params[:include]
      end

    private

      attr_reader :recruitment_cycle, :accredited_body, :training_provider

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_accredited_body
        @accredited_body = recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase,
        )
      end

      def build_training_provider
        @training_provider = recruitment_cycle.providers.find_by!(
          provider_code: params[:training_provider_code].upcase,
        )
      end
    end
  end
end
