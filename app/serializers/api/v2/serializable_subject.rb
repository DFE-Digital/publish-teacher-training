module API
  module V2
    class SerializableSubject < JSONAPI::Serializable::Resource
      type "subjects"

      attributes :subject_name, :subject_code
    end
  end
end
