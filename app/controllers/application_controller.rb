# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  include Pundit::Authorization
  include Pagy::Backend
  include Errorable

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end
end
