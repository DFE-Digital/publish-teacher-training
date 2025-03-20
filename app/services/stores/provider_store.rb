# frozen_string_literal: true

module Stores
  class ProviderStore < BaseStore
    FORM_STORE_KEYS = %i[
      urn
      location_details
    ].freeze

    def store_keys
      FORM_STORE_KEYS
    end
  end
end
