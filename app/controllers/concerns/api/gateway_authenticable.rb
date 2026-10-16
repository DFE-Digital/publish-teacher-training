# frozen_string_literal: true

module API
  module GatewayAuthenticable
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_gateway, if: -> { Settings.features.api_gateway_authentication }
    end

  private

    def authenticate_gateway
      return if gateway_secret_matches?

      render_json_error(status: 401)
    end

    def gateway_secret_matches?
      secret = Settings.api_gateway.secret.to_s
      return false if secret.blank?

      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(request.headers["X-Gateway-Secret"].to_s),
        ::Digest::SHA256.hexdigest(secret),
      )
    end
  end
end
