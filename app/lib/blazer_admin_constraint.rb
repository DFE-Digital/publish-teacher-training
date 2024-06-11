# frozen_string_literal: true

class BlazerAdminConstraint
  def matches?(request)
    signin_user = UserSession.load_from_session(request.session)
    return false if signin_user.blank?

    admin_user = User.admins.kept.find_by(email: signin_user.email)
    admin_user.present? && authorised_for_blazer?(admin_user)
  end

  private

  def authorised_for_blazer?(admin_user)
    allowed_ids.blank? || allowed_ids.split(',').include?(admin_user.id.to_s)
  end

  def allowed_ids
    ENV.fetch('BLAZER_ALLOWED_IDS', nil)
  end
end
