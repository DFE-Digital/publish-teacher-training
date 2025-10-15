# frozen_string_literal: true

class RecordFirstLoginService
  def execute(current_user:)
    return unless current_user.first_login_date_utc.nil?

    current_user.update(first_login_date_utc: Time.zone.now.utc)
  end
end
