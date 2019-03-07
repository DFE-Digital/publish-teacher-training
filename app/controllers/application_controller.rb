class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit

  # child must define authenticate method
  before_action :authenticate
  after_action :verify_authorized
end
