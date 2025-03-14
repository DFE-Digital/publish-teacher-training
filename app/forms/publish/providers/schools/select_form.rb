# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class SelectForm
        include ActiveModel::Model

        FIELDS = %i[
          school_id
        ].freeze

        attr_accessor(*FIELDS)

        validates :school_id, presence: true
      end
    end
  end
end
