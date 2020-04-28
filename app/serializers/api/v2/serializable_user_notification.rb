module API
  module V2
    class SerializableUserNotification < JSONAPI::Serializable::Resource
      type "user_notifications"

      attributes :course_create, :course_update

      belongs_to :user
      belongs_to :provider
    end
  end
end
