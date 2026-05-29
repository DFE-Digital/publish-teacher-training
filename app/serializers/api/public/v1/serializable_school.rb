# frozen_string_literal: true

module API
  module Public
    module V1
      class SerializableSchool < JSONAPI::Serializable::Resource
        extend JSONAPI::Serializable::Resource::ConditionalFields

        type "locations"

        belongs_to :course, through: :course_school, unless: -> { @course.nil? } do
          data { @course }
        end

        belongs_to :recruitment_cycle

        belongs_to :provider, through: :provider_school

        attributes :urn, :latitude, :longitude, :postcode #, :uuid, :region_code

        delegate :urn, :latitude, :longitude, :postcode, to: :gias_school
        delegate :gias_school, to: :object

        def recruitment_cycle
          @object.provider.recruitment_cycle
        end

        attribute :code do
          @object.site_code
        end

        attribute :postcode do
          @object.gias_school.postcode
        end

        attribute :longitude do
          @object.gias_school.longitude
        end

        attribute :latitude do
          @object.gias_school.latitude
        end

        attribute :urn do
          @object.gias_school.urn
        end

        attribute :name do
          @object.gias_school.name
        end

        attribute :city do
          @object.gias_school.town
        end

        attribute :county do
          @object.gias_school.county
        end

        attribute :street_address_1 do
          @object.gias_school.address1
        end

        attribute :street_address_2 do
          @object.gias_school.address2
        end

        attribute :street_address_3 do
          @object.gias_school.address3
        end
      end
    end
  end
end
