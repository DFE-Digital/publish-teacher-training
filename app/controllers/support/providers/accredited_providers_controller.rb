# frozen_string_literal: true

module Support
  module Providers
    class AccreditedProvidersController < SupportController
      layout 'provider_record'

      def index
        @accredited_providers = provider.accrediting_providers.order(:provider_name).page(params[:page] || 1)
      end

      private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end
    end
  end
end
