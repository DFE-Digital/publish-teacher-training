# frozen_string_literal: true

module Stores
  class ProviderStore < BaseStore
    FORM_STORE_KEYS = %i[
<<<<<<< HEAD
      raw_csv_school_details
      parsed_csv_school_details
      location_details
=======
      raw_csv_schools
      parsed_csv_schools
>>>>>>> main
    ].freeze

    def store_keys
      FORM_STORE_KEYS
    end

    private

    def identifier_id
      "#{self.class.name}_#{identifier_model.id}"
    end
  end
end
