class APIController < ActionController::API
  include EmitsRequestEvents
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit::Authorization

  # child must define authenticate method
  before_action :authenticate
  after_action :verify_authorized
end
