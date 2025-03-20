# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class URNForm < BaseForm
        FIELDS = %i[
          values
        ].freeze

        attr_accessor(*FIELDS)

        validates :values, presence: true, length: { maximum: 50 }

        alias compute_fields new_attributes
      end
    end
  end
end
