# frozen_string_literal: true

module Publish
  class ProviderContactForm < BaseProviderForm
    FIELDS = %i[
      email telephone urn website ukprn
      address1 address2 address3 town address4 postcode region_code
    ].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :provider_name, :lead_partner?, to: :provider

    validates :email, email_address: { message: 'Enter an email address in the correct format, like name@example.com' }
    validates :telephone, phone: true
    validates :website, presence: true, url: { message: 'Enter a website address in the correct format, like https://www.example.com' }
    validates :urn, reference_number_format: { allow_blank: false, minimum: 5, maximum: 6, message: 'URN must be 5 or 6 numbers' }, if: :lead_partner?
    validates :ukprn, ukprn_format: { allow_blank: false }
    validates :address1, :town, presence: true
    validates :postcode, presence: true, postcode: true

    private

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
