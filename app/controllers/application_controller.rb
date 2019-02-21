class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit

  # child must define authenticate method
  before_action :authenticate
end
