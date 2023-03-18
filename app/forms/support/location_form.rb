# frozen_string_literal: true

module Support
  class LocationForm < Form
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

    validates :location_name, presence: true
    validates :address1, presence: true
    validates :postcode, presence: true

    # Do we want to do this?
    # def display_urn
    #  urn.present? ? urn.to_s : 'Not entered'
    # end

    def full_address
      [address1, address2, address3, address4, postcode].select(&:present?).join('<br>').html_safe
    end

    private

    def form_store_key
      :location_details
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
