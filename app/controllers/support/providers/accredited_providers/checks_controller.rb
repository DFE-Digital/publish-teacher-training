# frozen_string_literal: true

module Support
  module Providers
    module AccreditedProviders
      class ChecksController < SupportController
        def show
          provider
          @accredited_provider_form = AccreditedProviderForm.new(current_user)
        end

        def update
          redirect_to support_recruitment_cycle_provider_accredited_providers_path(
            recruitment_cycle.year, provider.id
          ), flash: { success: 'Accredited provider added' }
        end

        private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end
      end
    end
  end
end
