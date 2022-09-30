# frozen_string_literal: true

module Stores
  class CourseStore < BaseStore
    FORM_STORE_KEYS = %i[
      funding_types_and_visas
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
