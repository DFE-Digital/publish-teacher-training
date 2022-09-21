# frozen_string_literal: true

module Stores
  class UserStore < BaseStore
    FORM_STORE_KEYS = %i[
      user
    ].freeze

    def store_keys
      FORM_STORE_KEYS
    end

  private

    def identifier_id
      identifier_model.id
    end
  end
end
