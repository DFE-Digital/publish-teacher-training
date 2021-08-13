class ApplicationController < ActionController::Base
  include EmitsRequestEvents
  before_action :authenticate

  include Pundit

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def user_session
    @user_session ||= UserSession.load_from_session(session)
  end

  def current_user
    @current_user ||= User.find_by(email: user_session&.email)
  end

  def authenticated?
    current_user.present?
  end

  def authenticate
    if !authenticated?
      redirect_to sign_in_path
    elsif !current_user.admin?
      flash[:error] = "User is not an admin"
      redirect_to sign_in_path
    end
  end
end
