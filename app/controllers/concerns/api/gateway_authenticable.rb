# frozen_string_literal: true

module API
  module GatewayAuthenticable
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_gateway, if: -> { Settings.features.api_gateway_authentication }
    end

  private

    def authenticate_gateway
      head :unauthorized unless gateway_secret_matches?
    end

    def gateway_secret_matches?
      ActiveSupport::SecurityUtils.secure_compare(
        request.headers["X-Gateway-Secret"].to_s,
        Settings.api_gateway.secret.to_s,
      )
    end
  end
end
