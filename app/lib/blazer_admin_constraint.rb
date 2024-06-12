# frozen_string_literal: true

class BlazerAdminConstraint
  def matches?(request)
    signin_user = UserSession.load_from_session(request.session)
    return false if signin_user.blank?

    admin_user = User.admins.kept.find_by(email: signin_user.email)
    admin_user.present? && authorised_for_blazer?(signin_user)
  end

  private

  def authorised_for_blazer?(signin_user)
    User.with_blazer_access.find_by(email: signin_user.email).present?
  end
end
