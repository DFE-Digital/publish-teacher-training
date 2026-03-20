# frozen_string_literal: true

class BlazerAdminConstraint
  def matches?(request)
    user = UserFromCookie.authenticated_user(request)
    return false if user.blank?

    user.blazer_access? && user.admin?
  end
end
