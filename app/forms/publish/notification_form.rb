module Publish
  class NotificationForm < BaseModelForm
    alias_method :user, :model

    FIELDS = %i[
      explicitly_enabled
    ].freeze

    attr_accessor(*FIELDS)

    validates :explicitly_enabled, inclusion: { in: [true, false], message: "Please select one option" }

    def save!
      if valid?
        user_notification_preferences.update(enable_notifications: explicitly_enabled)
      else
        false
      end
    end

  private

    def compute_fields
      { explicitly_enabled: preference_selected? }.merge(new_attributes).symbolize_keys
    end

    def user_notification_preferences
      @user_notification_preferences ||= UserNotificationPreferences.new(user_id: user.id)
    end

    def preference_selected?
      return if user_notification_preferences.updated_at.blank?

      user_notification_preferences.enabled?
    end
  end
end
