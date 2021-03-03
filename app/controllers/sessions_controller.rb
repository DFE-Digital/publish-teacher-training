class SessionsController < ApplicationController
  skip_before_action :authenticate

  def sign_out
    redirect_to "/auth/dfe/signout"
  end

  def failure
    render "errors/unauthorized", status: :unauthorized
  end

  def create
    DfESignInSession.begin_session!(session, request.env["omniauth.auth"])

    if current_user
      DfESignInUsers::Update.call(user: current_user, dfe_sign_in_user: dfe_sign_in_user)

      redirect_to gias_dashboard_path
    else
      DfESignInSession.end_session!(session)
      redirect_to sign_in_user_not_found_path
    end
  end

  def destroy
    if current_user.present?
      DfESignInSession.end_session!(session)
      redirect_to dfe_sign_in_user.logout_url
    else
      redirect_to gias_dashboard_path
    end
  end
end
