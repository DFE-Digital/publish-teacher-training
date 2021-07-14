module API
  module Public
    module V1
      class SerializableLocation < JSONAPI::Serializable::Resource
        extend JSONAPI::Serializable::Resource::ConditionalFields

        type "locations"

        belongs_to :course, unless: -> { @course.nil? } do
          data { @course }
        end

        belongs_to :location_status, unless: -> { @location_statuses.nil? } do
          data do
            # NOTE: This is using arrays otherwise it results in incurring N + 1
            @location_statuses.find do |location_status|
              location_status.site_id == @object.id
            end
          end
        end

        belongs_to :provider
        belongs_to :recruitment_cycle

        attributes :code,
                   :urn,
                   :latitude,
                   :longitude,
                   :postcode,
                   :region_code

        attribute :name do
          @object.location_name
        end

        attribute :city do
          @object.address3
        end

        attribute :county do
          @object.address4
        end

        attribute :street_address_1 do
          @object.address1
        end

        attribute :street_address_2 do
          @object.address2
        end
      end
    end
  end
end
