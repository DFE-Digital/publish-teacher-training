module API
  module V2
    class SerializableProvider < JSONAPI::Serializable::Resource
      type "providers"

      attributes :provider_code, :provider_name, :accredited_body?, :can_add_more_sites?,
                 :content_status, :accredited_bodies, :train_with_us, :train_with_disability,
                 :latitude, :longitude

      attribute :address1 do
        @object.external_contact_info["address1"]
      end

      attribute :address2 do
        @object.external_contact_info["address2"]
      end

      attribute :address3 do
        @object.external_contact_info["address3"]
      end

      attribute :address4 do
        @object.external_contact_info["address4"]
      end

      attribute :postcode do
        @object.external_contact_info["postcode"]
      end

      attribute :region_code do
        @object.external_contact_info["region_code"]
      end

      attribute :telephone do
        @object.external_contact_info["telephone"]
      end

      attribute :email do
        @object.external_contact_info["email"]
      end

      attribute :website do
        @object.external_contact_info["website"]
      end

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end

      attribute :last_published_at do
        @object.last_published_at&.iso8601
      end

      attribute :admin_contact do
        @object.generated_ucas_contact("admin")
      end

      attribute :utt_contact do
        @object.generated_ucas_contact("utt")
      end

      attribute :web_link_contact do
        @object.generated_ucas_contact("web_link")
      end

      attribute :fraud_contact do
        @object.generated_ucas_contact("fraud")
      end

      attribute :finance_contact do
        @object.generated_ucas_contact("finance")
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

      has_many :courses do
        meta do
          { count: @object.courses_count }
        end
      end
    end
  end
end
