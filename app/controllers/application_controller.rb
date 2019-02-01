class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate
  rescue_from PG::ConnectionBad, with: :render_service_unavailable

  def authenticate
    authenticate_or_request_with_http_token do |token|
      ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.authentication_token)
    end
  end

private

  def render_service_unavailable
    render json: { code: 503, status: 'Service Unavailable' }.to_json, status: 503
  end
end
