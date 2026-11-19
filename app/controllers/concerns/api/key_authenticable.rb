# frozen_string_literal: true

module API
  module KeyAuthenticable
    extend ActiveSupport::Concern

    BEARER_KEY = /\Abearer +(#{APIKeySecret::FORMAT})\z/i

    INVALID_AUTHORIZATION_NOTICE = "The Authorization header was not a valid active API key. It is currently ignored, " \
                                   "but requests with an invalid Authorization header will be rejected with 401 in future. " \
                                   "Remove the header or send an active API key."

    included do
      before_action :authenticate_api_key
    end

  private

    def authenticate_api_key
      header = request.headers["Authorization"]
      return if header.nil?

      token = header.b[BEARER_KEY, 1]
      api_key = APIKey.find_active_by_secret(token) if token

      if FeatureFlag.active?(:api_key_authentication)
        return reject_api_key unless api_key

        api_key.record_use!
      else
        warn_invalid_api_key unless api_key
      end
    end

    # Header validation is not enforced yet, so the request is still served.
    def warn_invalid_api_key
      response.headers["API-Auth-Notice"] = INVALID_AUTHORIZATION_NOTICE
      response.headers["Link"] = %(<#{Settings.api_url}/docs/authentication.html>; rel="deprecation")
    end

    def reject_api_key
      response.headers["WWW-Authenticate"] = "Bearer"
      render_json_error(status: 401)
    end
  end
end
