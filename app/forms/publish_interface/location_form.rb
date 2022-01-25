module PublishInterface
  class LocationForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

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
    attr_accessor :site, :provider, :params, :fields

    delegate :id, :persisted?, to: :site
    delegate :provider_code, :recruitment_cycle_year, to: :provider

    def initialize(site, params: {})
      @site = site
      @provider = site.provider
      @params = params
      @fields = compute_fields
      assign_attributes(fields)
    end

    validate :location_name_unique_to_provider
    validates :location_name, presence: { message: "Enter a name" }
    validates :address1, presence: { message: "Enter a building and street" }
    validates :postcode, presence: { message: "Enter a postcode" }
    validates :postcode, postcode: { message: "Postcode is not valid (for example, BN1 1AA)" }
    validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: "URN must be 5 or 6 numbers" }

    def save!
      if valid?
        assign_attributes_to_site
        site.save!
      else
        false
      end
    end

  private

    def assign_attributes_to_site
      site.assign_attributes(fields.except(*fields_to_ignore_before_save))
    end

    def compute_fields
      site.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def fields_to_ignore_before_save
      []
    end

    def new_attributes
      params
    end

    def location_name_unique_to_provider
      sibling_sites = provider.sites - [site]

      if location_name.in?(sibling_sites.pluck(:location_name))
        errors.add(:location_name, "Name is in use by another location")
      end
    end
  end
end
