class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_token do |token|
      ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.authentication_token)
    end
  end
end
