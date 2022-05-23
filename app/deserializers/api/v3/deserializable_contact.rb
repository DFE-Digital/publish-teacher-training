module API
  module V3
    class DeserializableContact < JSONAPI::Deserializable::Resource
      attributes :name, :email, :telephone, :permission_given, :type
    end
  end
end
