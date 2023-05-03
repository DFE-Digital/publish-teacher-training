# frozen_string_literal: true

module Support
  module Providers
    class OnboardingsController < SupportController
      include GotoConfirmationHelper

      def new
        @support_provider_form = ProviderForm.new(current_user, recruitment_cycle:)
      end

      def create
        @support_provider_form = ProviderForm.new(current_user, recruitment_cycle:, params: provider_form_params)

        if @support_provider_form.stash
          redirect_to redirect_path
        else
          render :new
        end
      end

      private

      def redirect_path
        if goto_confirmation?(param_form_key:, params:)
          support_recruitment_cycle_providers_onboarding_check_path
        else
          new_support_recruitment_cycle_providers_onboarding_contacts_path
        end
      end

      def param_form_key = :support_provider_form

      def provider_form_params
        params.require(param_form_key)
              .except(:goto_confirmation)
              .permit(ProviderForm::FIELDS)
      end
    end
  end
end
