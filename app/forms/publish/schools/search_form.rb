# frozen_string_literal: true

module Publish
  module Schools
    class SearchForm
      include ActiveModel::Model

      FIELDS = %i[
        query
      ].freeze

      attr_accessor(*FIELDS)

      validates :query, presence: true, length: { minimum: 2 }
    end
  end
end
