# frozen_string_literal: true

module Support
  module Providers
    class AccreditedPartnershipsController < ApplicationController
      def index
        @pagy, @partnerships = pagy(provider.accredited_partnerships.includes(:accredited_provider))
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end
    end
  end
end
