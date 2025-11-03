# frozen_string_literal: true

module Support
  class StudySiteForm < Form
    FIELDS = %i[
      gias_school_id
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
    validate :urn_unique_to_provider
    validates :location_name, presence: true
    validates :address1, presence: true
    validates :town, presence: true
    validates :postcode, presence: true
    validates :postcode, postcode: true
    validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: :format }

    def full_address
      address = [address1, address2, address3, town, address4, postcode]

      return "" if address.all?(&:blank?)

      address.compact_blank.join("<br>").html_safe
    end

  private

    def location_name_unique_to_provider
      errors.add(:location_name, :taken) if location_name.in?(site.siblings.kept.pluck(:location_name))
    end

    def urn_unique_to_provider
      return if urn.blank?

      errors.add(:urn, :taken) if urn.in?(site.siblings.kept.pluck(:urn))
    end

    def form_store_key
      :location_details
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def fields_to_ignore_before_save
      [:gias_school_id]
    end
  end
end
