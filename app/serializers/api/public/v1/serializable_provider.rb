# frozen_string_literal: true

module API
  module Public
    module V1
      class SerializableProvider < JSONAPI::Serializable::Resource
        type 'providers'

        belongs_to :recruitment_cycle

        attributes :ukprn,
                   :urn,
                   :postcode,
                   :provider_type,
                   :region_code,
                   :train_with_disability,
                   :train_with_us,
                   :website,
                   :latitude,
                   :longitude,
                   :telephone,
                   :email,
                   :can_sponsor_skilled_worker_visa,
                   :can_sponsor_student_visa

        attribute :accredited_body do
          @object.accredited_provider?
        end

        attribute :changed_at do
          @object.changed_at.iso8601
        end

        attribute :city do
          @object.town
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

        attribute :street_address_1 do
          @object.address1
        end

        attribute :street_address_2 do
          @object.address2
        end

        attribute :street_address_3 do
          @object.address3
        end
      end
    end
  end
end
