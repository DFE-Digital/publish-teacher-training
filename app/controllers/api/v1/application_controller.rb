module Api
  module V1
    class ApplicationController < ::ApplicationController
      include ActionController::HttpAuthentication::Token::ControllerMethods

      def authenticate
        authenticate_or_request_with_http_token do |token|
          ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.authentication_token)
        end
      end
    end
  end
end
