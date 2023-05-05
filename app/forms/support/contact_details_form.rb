# frozen_string_literal: true

module Support
  class ContactDetailsForm < ::Publish::BaseProviderForm
    FIELDS = %i[
      email telephone website
      address1 address2 address3 town address4 postcode
    ].freeze

    attr_accessor(*FIELDS)

    delegate :recruitment_cycle_year, :provider_code, :provider_name, :lead_school?, to: :provider

    validates :email, presence: true, email_address: true
    validates :telephone, phone: true
    validates :website, presence: true, url: true
    validates :address1, :town, presence: true
    validates :postcode, presence: true, postcode: true

    private

    def compute_fields
      provider.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
