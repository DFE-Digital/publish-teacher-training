class UserNotificationPreferencesPolicy
  def initialize(user, user_notification_preferences)
    @user = user
    @user_notification_preferences = user_notification_preferences
  end

  def show?
    user.present? && user_matches?
  end

  def update?
    user.present? && user_matches?
  end

private

  attr_reader :user, :user_notification_preferences

  def user_matches?
    user.id == user_notification_preferences.id
  end

  def update?
    true
  end
end
