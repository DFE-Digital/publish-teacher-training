# frozen_string_literal: true

module Publish
  module Providers
    module AccreditedProviders
      class ChecksController < PublishController
        before_action :authorize_provider

        def show
          provider
          accredited_provider_form
        end

        def update
          redirect_to publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year), flash: { success: 'Accredited provider added' }
        end

        private

        def accredited_provider_form
          @accredited_provider_form ||= AccreditedProviderForm.new(current_user)
        end

        def provider
          @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
        end

        def authorize_provider
          authorize(provider)
        end
      end
    end
  end
end
