module API
  module V2
    class DeserializableNotification < JSONAPI::Deserializable::Resource
      attributes :course_create,
                 :course_update
    end
  end
end
