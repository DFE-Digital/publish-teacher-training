module API
  module V2
    class SerializableUserNotificationPreferences < JSONAPI::Serializable::Resource
      type "user_notification_preferences"

      attributes :enabled, :updated_at
    end
  end
end
