# frozen_string_literal: true

module Publish
  class SchoolForm < BaseModelForm
    FIELDS = %i[
      location_name
      urn
      address1
      address2
      address3
      town
      address4
      postcode
      site_type
    ].freeze

    attr_accessor(*FIELDS)

    delegate :provider, to: :site
    delegate :provider_code, :recruitment_cycle_year, to: :provider

    def site
      @model
    end

    validate :location_name_unique_to_provider
    validates :location_name, presence: true
    validates :address1, presence: true
    validates :town, presence: true
    validates :postcode, presence: true
    validates :postcode, postcode: true
    validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: :format }

    private

    def assign_attributes_to_site
      site.assign_attributes(fields.except(*fields_to_ignore_before_save))
    end

    def compute_fields
      site.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def location_name_unique_to_provider
      sibling_sites = if site.study_site?
                        provider.study_sites - [site]
                      else
                        provider.sites - [site]
                      end
      errors.add(:location_name, 'Name is in use by another location') if location_name.in?(sibling_sites.pluck(:location_name))
    end
  end
end
