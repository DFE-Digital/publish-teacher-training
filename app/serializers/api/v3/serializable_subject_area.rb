module API
  module V3
    class SerializableSubjectArea < JSONAPI::Serializable::Resource
      type "subject_areas"
      has_many :subjects

      attributes :name
      attributes :typename
    end
  end
end
