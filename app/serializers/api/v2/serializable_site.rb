module API
  module V2
    class SerializableSite < JSONAPI::Serializable::Resource
      type 'sites'

      attributes :code, :location_name, :address1, :address2,
                 :address3, :address4, :postcode, :region_code

      attribute :recruitment_cycle do
        @object.recruitment_cycle.year
      end
    end
  end
end
