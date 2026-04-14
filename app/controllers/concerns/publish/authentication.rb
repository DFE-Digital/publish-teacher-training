# frozen_string_literal: true

module Publish
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
      before_action :load_user_session
      before_action :authenticate
    end

    def current_user
      @current_user ||= Current.session&.sessionable
    end

    def authenticated?
      resume_session
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

  private

    def load_user_session
      session.delete("user") if session["user"].present?
      resume_session
    end

    def resume_session
      Current.session ||= find_user_session
    end

    def find_user_session
      return unless user_session_key

      db_session = Session.find_by(session_key: user_session_key)
      return unless db_session
      return unless db_session.sessionable_type == "User"

      unless db_session.active?
        db_session.destroy!
        reset_user_session_cookie
        return
      end

      db_session.touch
      db_session
    end

    def start_user_session(user, id_token: nil)
      ::Authentication.transaction do
        terminate_user_session
        user.sessions.destroy_all

        user.sessions.create!(
          session_key: user_session_key,
          id_token: id_token,
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
        ).tap do |db_session|
          Current.session = db_session
        end
      end
    end

    def terminate_user_session
      Current.session&.destroy!
      Current.session = nil
      reset_user_session_cookie
    end

    # Cookie management

    def user_session_key
      cookies.signed[user_session_cookie_name] ||= new_user_session_cookie
      cookies.signed[user_session_cookie_name]
    end

    def reset_user_session_cookie
      cookies.signed[user_session_cookie_name] = new_user_session_cookie
    end

    def new_user_session_cookie
      {
        value: SecureRandom.hex(32),
        httponly: true,
        same_site: :lax,
        secure: !Rails.env.in?(%(development test)),
      }
    end

    def user_session_cookie_name
      Settings.cookies.user_session.name
    end
  end
end
