module API
  module V2
    class SerializableSite < JSONAPI::Serializable::Resource
      type 'site'

      attributes :code, :location_name
    end
  end
end
