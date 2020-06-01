class UserNotificationPreferences
  def initialize(user_id:)
    @user_id = user_id
  end

  def id
    @user_id&.to_i
  end

  def enabled
    # course_publish and course_update currently always have the same value
    user_notifications.select(&:course_publish).any?
  end

  def updated_at
    return nil if user_notifications.empty?

    user_notifications.maximum(:updated_at).iso8601
  end

  def update(enable_notifications:)
    UserNotification.transaction do
      rollback_on_error do
        UserNotification.where(user_id: id).destroy_all

        user_accredited_body_codes.each do |provider_code|
          UserNotification.create(
            user_id: id,
            course_publish: enable_notifications,
            course_update: enable_notifications,
            provider_code: provider_code,
          )
        end
      end
    end

    reset_user_notifications

    self
  end

  alias_method :enabled?, :enabled

private

  def user_accredited_body_codes
    user.providers.accredited_body.in_current_cycle.distinct.pluck(:provider_code)
  end

  def user_notifications
    @user_notifications ||= UserNotification.where(user_id: id)
  end

  def reset_user_notifications
    @user_notifications = nil
  end

  def user
    @user ||= User.find(id)
  end

  def rollback_on_error
    yield
  rescue StandardError => e
    Raven.capture(e)
    raise ActiveRecord::Rollback
  end
end
