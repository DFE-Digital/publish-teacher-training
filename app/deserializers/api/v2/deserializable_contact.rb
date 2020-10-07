module API
  module V2
    class DeserializableContact < JSONAPI::Deserializable::Resource
      attributes :name, :email, :telephone, :permission_given, :type
    end
  end
end
