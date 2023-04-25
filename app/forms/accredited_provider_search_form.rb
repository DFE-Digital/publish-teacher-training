# frozen_string_literal: true

class AccreditedProviderSearchForm
  include ActiveModel::Model

  FIELDS = %i[
    query
  ].freeze

  attr_accessor(*FIELDS)

  validates :query, presence: true, length: { minimum: 2 }
end
