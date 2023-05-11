# frozen_string_literal: true

module Publish
  module Providers
    class AccreditedProvidersController < PublishController
      def index
        authorize_provider
        provider
      end

      def provider
        @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code] || params[:code])
      end

      def authorize_provider
        authorize(provider)
      end
    end
  end
end
