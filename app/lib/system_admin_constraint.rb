# frozen_string_literal: true

class SystemAdminConstraint
  def matches?(request)
    system_admin?(request)
  end

  def system_admin?(request)
    user = user_from_session(request)
    user.present? && user.admin?
  end

private

  def user_from_session(request)
    session_key = request.cookie_jar.signed[Settings.cookies.user_session.name]
    return unless session_key

    db_session = Session.find_by(session_key:, sessionable_type: "User")
    return unless db_session

    db_session.sessionable
  end
end
