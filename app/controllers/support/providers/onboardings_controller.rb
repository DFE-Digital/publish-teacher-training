# frozen_string_literal: true

module Support
  module Providers
    class OnboardingsController < SupportController
      def new
        @provider = ProviderForm.new(current_user, recruitment_cycle:)
      end

      def create
        @provider = ProviderForm.new(current_user, recruitment_cycle:, params: provider_form_params)

        if @provider.valid?
          redirect_to support_recruitment_cycle_providers_path(recruitment_cycle.year), flash: { success: 'Provider was successfully created' }
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
