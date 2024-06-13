# frozen_string_literal: true

class BlazerAdminConstraint
  def matches?(request)
    signin_user = UserSession.load_from_session(request.session)
    return false if signin_user.blank?

    User.with_blazer_access.kept.exists?(email: signin_user.email)
  end
end
