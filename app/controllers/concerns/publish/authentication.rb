# frozen_string_literal: true

module Publish
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
      before_action :authenticate
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
      return if authenticated?

      session["post_dfe_sign_in_path"] = request.fullpath
      if Publish::AuthenticationService.persona?
        redirect_to sign_in_path({ support: params[:controller].start_with?("support") })
      else
        redirect_to sign_in_path
      end
    end
  end
end
