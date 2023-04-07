# frozen_string_literal: true

module Publish
  class SchoolForm < BaseModelForm
    FIELDS = %i[
      location_name
      urn
      address1
      address2
      town
      address4
      postcode
    ].freeze

    attr_accessor(*FIELDS)

    delegate :provider, to: :site
    delegate :provider_code, :recruitment_cycle_year, to: :provider

    def site
      @model
    end

    validate :location_name_unique_to_provider
    validates :location_name, presence: { message: 'Enter a name' }
    validates :address1, presence: { message: 'Enter a building and street' }
    validates :town, presence: { message: 'Enter a town or city' }
    validates :postcode, presence: { message: 'Enter a postcode' }
    validates :postcode, postcode: { message: 'Postcode is not valid (for example, BN1 1AA)' }
    validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: 'URN must be 5 or 6 numbers' }

    private

    def assign_attributes_to_site
      site.assign_attributes(fields.except(*fields_to_ignore_before_save))
    end

    def compute_fields
      site.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def location_name_unique_to_provider
      sibling_sites = provider.sites - [site]

      errors.add(:location_name, 'Name is in use by another location') if location_name.in?(sibling_sites.pluck(:location_name))
    end
  end
end
