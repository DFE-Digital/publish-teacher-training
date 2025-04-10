# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  include Authentication

  helper_method :current_user
  before_action :authenticate

  include Pundit::Authorization
  include Pagy::Backend

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def render_not_found
    render "errors/not_found", status: :not_found, formats: :html
  end
end
