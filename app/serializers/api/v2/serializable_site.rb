module API
  module V2
    class SerializableSite < JSONAPI::Serializable::Resource
      type 'sites'

      attributes :code, :location_name
    end
  end
end
