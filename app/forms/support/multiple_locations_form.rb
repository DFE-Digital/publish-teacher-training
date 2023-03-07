# frozen_string_literal: true

module Support
  class MultipleLocationsForm < Form
    FIELDS = %i[
      location_details
    ].freeze

    attr_accessor(*FIELDS)

    validates :location_details, presence: true

    def compute_fields
      model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    # will change in follow up PR
    def form_store_key = :user
  end
end
