module Authentication
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
      session["post_dfe_sign_in_path"] = request.fullpath
      redirect_to sign_in_path
    end
  end
end
