# frozen_string_literal: true

module Support
  module Providers
    class OnboardingsController < SupportController
      def new
        @provider_form = ProviderForm.new(current_user, recruitment_cycle:)
      end

      def create
        @provider_form = ProviderForm.new(current_user, recruitment_cycle:, params: provider_form_params)

        if @provider_form.stash
          redirect_to new_support_recruitment_cycle_providers_onboarding_contacts_path(recruitment_cycle.year)
        else
          render :new
        end
      end

      private

      def provider_form_params
        params.require(:support_provider_form)
              .permit(ProviderForm::FIELDS)
      end
    end
  end
end
