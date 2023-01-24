# frozen_string_literal: true

class SystemAdminConstraint
  def matches?(request)
    system_admin?(request)
  end

  def system_admin?(request)
    signin_user = UserSession.load_from_session(request.session)
    signin_user.present? && User.admins.kept.exists?(email: signin_user.email)
  end
end
