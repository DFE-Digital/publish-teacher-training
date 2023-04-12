# frozen_string_literal: true

module Stores
  class UserStore < BaseStore
    FORM_STORE_KEYS = %i[
      user
      provider
    ].freeze

    def store_keys
      FORM_STORE_KEYS
    end
  end
end
