module API
  module V2
    class DeserializableSite < JSONAPI::Deserializable::Resource
      attributes :address1,
                 :address2,
                 :address3,
                 :address4,
                 :code,
                 :location_name,
                 :postcode,
                 :region_code
    end
  end
end
