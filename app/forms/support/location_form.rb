# frozen_string_literal: true

module Support
  class LocationForm < Form
    MAIN_SITE = 'main site'
    FIELDS = %i[
      location_name
      urn
      address1
      address2
      address3
      address4
      postcode
    ].freeze

    attr_accessor(*FIELDS)

    validates :location_name,
              :address1,
              :address3,
              :postcode,
              presence: true
    validates :postcode, postcode: true
    validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: I18n.t('activemodel.errors.models.support/location_form.attributes.urn.format') }
    validate :site_name_is_unique

    def full_address
      address = [address1, address2, address3, address4, postcode]
      address.unshift(location_name) unless location_name.downcase == MAIN_SITE

      return '' if address.all?(&:blank?)

      address.select(&:present?).join('<br>').html_safe
    end

    private

    def site_name_is_unique
      return unless @identifier_model.sites.exists?(location_name:)

      errors.add(:location_name, I18n.t('activemodel.errors.models.support/location_form.attributes.location_name.taken'))
    end

    def form_store_key
      :location_details
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
