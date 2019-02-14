class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate
  rescue_from PG::ConnectionBad, with: :render_service_unavailable

  # TODO: move the JWT token authentication to a V2 controller, and restrict
  #       the current authentication to V1
  def authenticate
    authenticate_or_request_with_http_token do |token|
      # ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.config.authentication_token)
      (json_payload, _options) = JWT.decode(token,
                                           Settings.authentication.secret,
                                           Settings.authentication.encoding)
      payload = JSON.parse(json_payload)
      @user = User.find_by(email: payload['email'])
      @user.present?
    end
  end

private

  def render_service_unavailable
    render json: { code: 503, status: 'Service Unavailable' }.to_json, status: 503
  end
end
