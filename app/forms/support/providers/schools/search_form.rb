# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class SearchForm
        include ActiveModel::Model

        FIELDS = %i[
          query
          school
        ].freeze

        attr_accessor(*FIELDS, :provider)

        validates :query, presence: true, length: { minimum: 2 }, on: :query
        validate :valid_school, on: :school

        def valid_school
          errors.add(:school, :school_already_exists) if provider.schools.exists?(gias_school: school)
        end
      end
    end
  end
end
