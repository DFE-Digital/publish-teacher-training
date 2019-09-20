module API
  module V2
    class DeserializableProvider < JSONAPI::Deserializable::Resource
      PROVIDER_ATTRIBUTES = %i[
        train_with_us
        train_with_disability
        email
        telephone
        website
        address1
        address2
        address3
        address4
        postcode
        region_code
        accredited_bodies
        admin_contact
        utt_contact
        web_link_contact
        fraud_contact
        finance_contact
        type_of_gt12
        gt12_contact
        send_application_alerts
        application_alert_contact
      ].freeze

      attributes(*PROVIDER_ATTRIBUTES)

      has_many :sites
      has_many :courses

      def reverse_mapping
        declared_attributes = DeserializableProvider.attr_blocks.keys
        declared_attributes
          .map { |key| [key.to_sym, "/data/attributes/#{key}"] }
          .to_h
      end
    end
  end
end
