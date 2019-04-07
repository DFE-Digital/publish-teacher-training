module API
  module V2
    class SerializableSite < JSONAPI::Serializable::Resource
      type 'sites'

      attributes :code, :location_name, :address1, :address2,
      :address3, :address4, :postcode, :region_code
    end
  end
end
