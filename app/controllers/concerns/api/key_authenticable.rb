# frozen_string_literal: true

module API
  module KeyAuthenticable
    extend ActiveSupport::Concern

    BEARER_KEY = /\Abearer +(#{APIKeySecret::FORMAT})\z/i

    included do
      before_action :authenticate_api_key
    end

  private

    def authenticate_api_key
      header = request.headers["Authorization"]
      return if header.nil?

      token = header.b[BEARER_KEY, 1]
      reject_api_key unless token && APIKey.find_active_by_secret(token)
    end

    def reject_api_key
      response.headers["WWW-Authenticate"] = "Bearer"
      render_json_error(status: 401)
    end
  end
end
