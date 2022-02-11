module Publish
  class ProviderContactForm < BaseProviderForm
    FIELDS = %i[
      email telephone urn website ukprn
      address1 address2 address3 address4 postcode region_code
    ].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :provider_name, :lead_school?, to: :provider

    validates :email, email_address: { message: "Enter an email address in the correct format, like name@example.com" }
    validates :telephone, phone: { message: "Enter a valid telephone number" }
    validates :urn, reference_number_format: { allow_blank: false, minimum: 5, maximum: 6, message: "URN must be 5 or 6 numbers" }, if: :lead_school?
    validates :ukprn, reference_number_format: { allow_blank: false, minimum: 8, maximum: 8, message: "UKPRN must be 8 numbers" }

  private

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
