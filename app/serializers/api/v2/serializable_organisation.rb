module API
  module V2
    class SerializableOrganisation < JSONAPI::Serializable::Resource
      type "organisations"
      has_many :users
      attributes :name
    end
  end
end
