# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class SearchForm
        include ActiveModel::Model

        FIELDS = %i[
          query
          school
        ].freeze

        attr_accessor(*FIELDS)

        validates :query, presence: true, length: { minimum: 2 }, on: :query

        validate :valid_school, on: :school

        def valid_school
          errors.add(:school, :school_already_exists) unless school.valid?
        end
      end
    end
  end
end
