# frozen_string_literal: true

module Sandbox
  # Turns a provider's attributes from the public Publish API into attributes
  # for an empty Provider: its identity, address and contact details, without
  # its descriptive text. Pure: it doesn't touch the database.
  class ProviderAttributesMapper
    FIELDS = %w[
      ukprn
      urn
      postcode
      provider_type
      region_code
      latitude
      longitude
      website
      telephone
      email
      can_sponsor_skilled_worker_visa
      can_sponsor_student_visa
      selectable_school
    ].freeze

    RENAMED_FIELDS = {
      "code" => "provider_code",
      "name" => "provider_name",
      "street_address_1" => "address1",
      "street_address_2" => "address2",
      "street_address_3" => "address3",
      "city" => "town",
      "county" => "address4",
    }.freeze

    def initialize(attributes)
      @attributes = attributes
    end

    # Never accredited: the API doesn't give the accredited provider number
    # that an accredited provider needs.
    def attributes
      RENAMED_FIELDS.to_h { |api_field, field| [field, @attributes[api_field]] }
        .merge(@attributes.slice(*FIELDS))
        .merge("accredited" => false)
    end
  end
end
