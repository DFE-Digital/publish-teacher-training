# frozen_string_literal: true

class SystemAdminConstraint
  def matches?(request)
    system_admin?(request)
  end

  def system_admin?(request)
    user = UserFromCookie.authenticated_user(request)
    user.present? && user.admin?
  end
end
