class SessionsController < ApplicationController

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
      UserSessions::Update.call(user: current_user, user_session: user_session)

      target_path = session.delete('post_dfe_sign_in_path')
      redirect_to target_path
    else
      UserSession.end_session!(session)

      redirect_to user_not_found_path
    end
  end

  def destroy
    if current_user.present?
      UserSession.end_session!(session)
      redirect_to user_session.logout_url
    else
      redirect_to support_providers_path
    end
  end
end
