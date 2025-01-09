# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    include DfE::Analytics::Requests
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include Pundit::Authorization

    # child must define authenticate method
    before_action :authenticate
    after_action :verify_authorized
  end
end
