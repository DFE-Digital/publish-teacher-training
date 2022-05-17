module API
  module V2
    class SerializableContact < JSONAPI::Serializable::Resource
      type "contacts"

      attributes :name, :email, :telephone, :type
    end
  end
end
