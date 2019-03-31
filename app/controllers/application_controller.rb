class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit

  # child must define authenticate method
  before_action :authenticate
  before_action :bat_environment
  after_action :verify_authorized
end
