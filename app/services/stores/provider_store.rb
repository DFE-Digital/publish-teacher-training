# frozen_string_literal: true

module Stores
  class ProviderStore < BaseStore
    FORM_STORE_KEYS = %i[
      raw_csv_schools
      parsed_csv_school_details
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
