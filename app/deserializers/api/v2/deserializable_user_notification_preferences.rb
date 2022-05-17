module API
  module V2
    class DeserializableUserNotificationPreferences < JSONAPI::Deserializable::Resource
      attributes :enabled
    end
  end
end
