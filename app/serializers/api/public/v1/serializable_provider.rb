# frozen_string_literal: true

module API
  module Public
    module V1
      class SerializableProvider < JSONAPI::Serializable::Resource
        extend JSONAPI::Serializable::Resource::ConditionalFields

        type "providers"

        belongs_to :recruitment_cycle

        attributes :ukprn,
                   :urn,
                   :postcode,
                   :provider_type,
                   :region_code,
                   :train_with_disability,
                   :website,
                   :latitude,
                   :longitude,
                   :telephone,
                   :email,
                   :can_sponsor_skilled_worker_visa,
                   :can_sponsor_student_visa,
                   :selectable_school

        attribute :train_with_us do
          if @object.recruitment_cycle.after_2025?
            [@object.about_us.to_s, @object.value_proposition.to_s].compact_blank.join("\r\n\r\n")
          else
            @object.train_with_us
          end
        end

        attribute :accredited_body do
          @object.accredited?
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

        attribute :discarded_at, if: -> { @object.discarded? }
      end
    end
  end
end
