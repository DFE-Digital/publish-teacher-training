module UserFromCookie
module_function

  def authenticated_user(request)
    session_key = request.cookie_jar.signed[Settings.cookies.user_session.name]
    return unless session_key

    db_session = Session.find_by(session_key:, sessionable_type: "User")
    return unless db_session

    unless db_session.active?
      db_session.destroy!
      return
    end

    db_session.sessionable
  end
end
