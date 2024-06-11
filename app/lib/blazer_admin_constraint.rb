# frozen_string_literal: true

class BlazerAdminConstraint
  def matches?(request)
    system_admin?(request)
  end

  def system_admin?(request)
    signin_user = UserSession.load_from_session(request.session)
    signin_user.present? && User.admins.kept.exists?(email: signin_user.email) && authorised_for_blazer?(signin_user)
  end

  def authorised_for_blazer?(signin_user)
    ENV['BLAZER_ALLOWED_IDS'].blank? || ENV['BLAZER_ALLOWED_IDS'].split(',').include?(User.admins.find_by(email: signin_user.email).id.to_s)
  end
end
