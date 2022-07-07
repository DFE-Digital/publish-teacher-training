class SessionsController < ApplicationController
  skip_before_action :authenticate

  def sign_out
    if AuthenticationService.persona?
      redirect_to "/auth/developer/signout"
    else
      redirect_to "/auth/dfe/signout"
    end
  end

  def callback
    UserSession.begin_session!(session, request.env["omniauth.auth"])

    if current_user
      UserSessions::Update.call(user: current_user, user_session:)

      redirect_to after_sign_in_path
    else
      UserSession.end_session!(session)

      redirect_to user_not_found_path
    end
  end

  def destroy
    session.delete(:cycle_year)
    if current_user.present?
      UserSession.end_session!(session)
      redirect_to(user_session.logout_url, allow_other_host: true)
    else
      redirect_to publish_root_path
    end
  end

private

  def after_sign_in_path
    saved_path = session.delete("post_dfe_sign_in_path")

    saved_path || publish_root_path
  end
end
