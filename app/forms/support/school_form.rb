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
    # what do we do with this?
    validate :validate_code
    validates :location_name, presence: { message: 'Enter a name' }
    validates :address1, presence: { message: 'Enter a building and street' }
    validates :town, presence: { message: 'Enter a town or city' }
    validates :postcode, presence: { message: 'Enter a postcode' }
    validates :postcode, postcode: true
    validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: 'URN must be 5 or 6 numbers' }

    def full_address
      address = [address1, address2, address3, town, address4, postcode]

      return '' if address.all?(&:blank?)

      address.select(&:present?).join('<br>').html_safe
    end

    private

    def location_name_unique_to_provider
      sibling_sites = if site_type == 'study_type'
                        provider.study_sites - [site]
                      else
                        provider.sites - [site]
                      end
      errors.add(:location_name, 'Name is in use by another location') if location_name.in?(sibling_sites.pluck(:location_name))
    end

    def validate_code
      return if site_type == 'study_site'

      errors.add(:code, 'Code has already been taken') if provider.sites.exists?(code:)
    end

    # def site
    #  @site ||= @identifier_model.sites.build(fields)
    # end

    def form_store_key
      :location_details
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
