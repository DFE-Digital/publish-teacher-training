module API
  module Public
    module V1
      class SerializableSubjectArea < JSONAPI::Serializable::Resource
        type "subject_areas"

        has_many :subjects

        attributes :name, :typename
      end
    end
  end
end
