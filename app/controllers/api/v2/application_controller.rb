module Api
  module V2
    class ApplicationController < ::ApplicationController
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate

      def authenticate
        authenticate_or_request_with_http_token do |token|
          (json_payload, _options) = JWT.decode(token,
                                               Settings.authentication.secret,
                                               Settings.authentication.encoding)
          payload = JSON.parse(json_payload)
          @user = User.find_by(email: payload['email'])
          @user.present?
        end
      end
    end
  end
end
