module Api
  module V1
    class ApplicationController < ActionController::API
      include ActionController::HttpAuthentication::Basic::ControllerMethods
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate

      def authenticate
        authenticate_or_request_with_http_basic('Administration') do |username, password|
          password == AUTHENTICATION[username]
        end
      end
    end
  end
end
