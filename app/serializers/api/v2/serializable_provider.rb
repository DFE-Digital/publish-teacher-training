module API
  module V2
    class SerializableProvider < JSONAPI::Serializable::Resource
      type "providers"

      attributes :provider_code, :provider_name, :provider_type, :accredited_body?, :can_add_more_sites?,
                 :accredited_bodies, :train_with_us, :train_with_disability,
                 :latitude, :longitude, :address1, :address2, :address3, :address4,
                 :postcode, :region_code, :telephone, :email, :website, :ukprn, :urn

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end

      attribute :gt12_contact do
        @object.ucas_preferences&.gt12_response_destination
      end

      attribute :application_alert_contact do
        @object.ucas_preferences&.application_alert_email
      end

      attribute :type_of_gt12 do
        @object.ucas_preferences&.type_of_gt12
      end

      attribute :send_application_alerts do
        @object.ucas_preferences&.send_application_alerts
      end

      has_many :sites
      has_many :users
      has_many :contacts

      has_many :courses do
        meta do
          { count: @object.courses_count }
        end
      end
    end
  end
end
