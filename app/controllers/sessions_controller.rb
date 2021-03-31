class SessionsController < ApplicationController
  skip_before_action :authenticate

  def sign_out
    redirect_to "/auth/dfe/signout"
  end

  def callback
    UserSession.begin_session!(session, request.env["omniauth.auth"])

    if current_user
      UserSessions::Update.call(user: current_user, user_session: user_session)

      redirect_to "/"
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
      redirect_to "/"
    end
  end
end
