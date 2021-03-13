class ApplicationController < ActionController::Base
  before_action :authenticate

  include Pundit

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def dfe_sign_in_user
    @dfe_sign_in_user ||= DfESignInSession.load_from_session(session)
  end

  def current_user
    @current_user ||= User.find_by(email: dfe_sign_in_user&.email)
  end

  def authenticated?
    current_user.present?
  end

  def authenticate
    return if Rails.env.development?

    if !authenticated?
      redirect_to sign_in_path
    elsif !current_user.admin?
      flash[:error] = "User is not an admin"
      redirect_to sign_in_path
    end
  end
end
