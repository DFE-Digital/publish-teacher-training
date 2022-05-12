if AuthenticationService.magic_link?
  class MagicLinkSessionsController < ApplicationController
    layout "application"

    skip_before_action :authenticate

    before_action :redirect_if_token_is_invalid
    before_action :redirect_if_token_expired

    def create
      update_user
      set_user_session
      record_first_login
      send_welcome_email

      redirect_to root_path
    end

  private

    def magic_link_params
      params.permit(:email, :token)
    end

    def redirect_if_token_is_invalid
      return unless params[:token] != user.magic_link_token

      redirect_to root_path, flash: {
        error: {
          id: "publish-authentication-magic-link-form-email-field",
          message: t("publish_authentication.magic_link.invalid_token"),
        },
      }
    end

    def redirect_if_token_expired
      return unless magic_link_token_expired?

      redirect_to root_path, flash: {
        error: {
          id: "publish-authentication-magic-link-form-email-field",
          message: t("publish_authentication.magic_link.expired"),
        },
      }
    end

    def user
      @user ||= User.find_by(email: magic_link_params[:email])
    end

    def magic_link_token_expired?
      magic_link_token_age = Time.zone.now - user.magic_link_token_sent_at

      magic_link_token_age > Settings.magic_link.max_token_age.seconds
    end

    def update_user
      user.update!(
        last_login_date_utc: Time.now.utc,
        magic_link_token: nil,
        magic_link_token_sent_at: nil,
      )
    end

    def set_user_session
      session["user"] = {
        "email" => user.email,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "last_active_at" => Time.zone.now,
      }
    end

    def record_first_login
      RecordFirstLoginService.new.execute(current_user: user)
    end

    def send_welcome_email
      SendWelcomeEmailService.call(current_user: user)
    end
  end
end
