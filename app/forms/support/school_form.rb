# frozen_string_literal: true

module Support
  class SchoolForm < Form
    FIELDS = %i[
      location_name
      urn
      code
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

    def full_address
      address = [address1, address2, address3, town, address4, postcode]

      return '' if address.all?(&:blank?)

      address.compact_blank.join('<br>').html_safe
    end

    private

    def location_name_unique_to_provider
      sibling_sites = if site.study_site?
                        provider.study_sites - [site]
                      else
                        provider.sites - [site]
                      end
      errors.add(:location_name, 'Name is in use by another location') if location_name.in?(sibling_sites.pluck(:location_name))
    end

    def form_store_key
      :location_details
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
