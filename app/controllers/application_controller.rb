class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # child must define authenticate method
  before_action :authenticate
  rescue_from PG::ConnectionBad, with: :render_service_unavailable

private

  def render_service_unavailable
    render json: { code: 503, status: 'Service Unavailable' }.to_json, status: 503
  end
end
