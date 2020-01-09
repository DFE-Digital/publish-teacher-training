module API
  module V2
    class AccreditedProviderTrainingProvidersController < ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider

      def index
        authorize @provider, :can_list_training_providers?
        providers = @provider.training_providers

        render jsonapi: providers, include: params[:include]
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_provider
        @provider = @recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase,
        )
      end
    end
  end
end
