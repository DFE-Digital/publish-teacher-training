module API
  module V2
    class SerializableOrganisation < JSONAPI::Serializable::Resource
      type "organisations"
      has_many :users
      has_many :providers
      attributes :name
    end
  end
end
