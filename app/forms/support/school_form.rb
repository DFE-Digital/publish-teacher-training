# frozen_string_literal: true

module Support
  class SchoolForm < Form
    # MAIN_SITE = 'main site'
    FIELDS = %i[
      location_name
      urn
      code
      address1
      address2
      address3
      address4
      postcode
    ].freeze

    attr_accessor(*FIELDS)

    validate :validate_site

    def full_address
      address = [address1, address2, address3, address4, postcode]

      return '' if address.all?(&:blank?)

      address.select(&:present?).join('<br>').html_safe
    end

    private

    def validate_site
      skip = []
      return if site.valid?

      sites = @identifier_model.sites.where.not(id: nil)
      skip << :location_name unless sites.exists?(location_name:) || location_name.blank?
      skip << :code unless sites.exists?(code:)

      promote_errors(site.errors, skip)
    end

    def promote_errors(site_errors, skip)
      site_errors.each do |site_error|
        next if skip.include?(site_error.attribute)

        errors.add(site_error.attribute, site_error.message)
      end
    end

    def site
      @site ||= @identifier_model.sites.build(fields)
    end

    def form_store_key
      :location_details
    end

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
