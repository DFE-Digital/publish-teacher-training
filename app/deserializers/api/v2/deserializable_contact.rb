module API
  module V2
    class DeserializableContact < JSONAPI::Deserializable::Resource
      attributes :name, :email, :telephone, :type
    end
  end
end
