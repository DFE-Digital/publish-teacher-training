module API
  module Public
    module V1
      class SerializableProvider < JSONAPI::Serializable::Resource
        type "providers"

        attributes :postcode,
                   :provider_type,
                   :region_code,
                   :train_with_disability,
                   :train_with_us,
                   :website

        attribute :accredited_body do
          @object.accredited_body?
        end

        attribute :changed_at do
          @object.changed_at.iso8601
        end

        attribute :city do
          @object.address3
        end

        attribute :code do
          @object.provider_code
        end

        attribute :county do
          @object.address4
        end

        attribute :created_at do
          @object.created_at.iso8601
        end

        attribute :name do
          @object.provider_name
        end

        attribute :recruitment_cycle_year do
          @object.recruitment_cycle.year
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
