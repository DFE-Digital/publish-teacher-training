module API
  module Public
    module V1
      class SerializableLocation < JSONAPI::Serializable::Resource
        type "locations"

        attributes :code,
                   :latitude,
                   :location_name,
                   :longitude,
                   :postcode,
                   :region_code

        attribute :street_address_1 do
          @object.address1
        end

        attribute :street_address_2 do
          @object.address2
        end

        attribute :city do
          @object.address3
        end

        attribute :county do
          @object.address4
        end

        attribute :recruitment_cycle_year do
          @object.recruitment_cycle.year
        end
      end
    end
  end
end
