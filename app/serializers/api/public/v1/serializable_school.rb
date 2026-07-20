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

        belongs_to :location_status, if: -> { @object.is_a?(Course::School) } do
          data { API::Public::V1::SchoolLocationStatus.new(@object) }
        end

        belongs_to :recruitment_cycle

        belongs_to :provider, through: :provider_school

        delegate :gias_school, to: :object

        def recruitment_cycle
          @object.provider.recruitment_cycle
        end

        def main_site?
          @object.site_code == Provider::School::MAIN_SITE_CODE
        end

        attribute :code do
          @object.site_code
        end

        attribute :urn do
          @object.gias_school.urn
        end

        attribute :latitude do
          @object.gias_school.latitude
        end

        attribute :longitude do
          @object.gias_school.longitude
        end

        attribute :postcode do
          @object.gias_school.postcode
        end

        attribute :region_code do
          region_code_from(@object.gias_school.region_code)
        end

        attribute :uuid do
          # For a Course::School this delegates to its provider_school; a
          # Provider::School exposes its own uuid column.
          @object.uuid
        end

        attribute :name do
          name = @object.gias_school.name
          main_site? ? "#{name} (Main site)" : name
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
