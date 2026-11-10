# frozen_string_literal: true

module Support
  module Providers
    class OnboardingsController < ApplicationController
      include BaseWizardController

      before_action :recruitment_cycle

    private

      def wizard_class = AddProviderWizard

      def wizard_context = { recruitment_cycle_year: params[:recruitment_cycle_year] }

      def wizard_success_message = "Organisation added"

      def wizard_completed_path
        support_recruitment_cycle_provider_path(params[:recruitment_cycle_year], wizard.created_provider)
      end
    end
  end
end
