# frozen_string_literal: true

class AccreditedProviderSelectForm
  include ActiveModel::Model

  FIELDS = %i[
    provider_id
  ].freeze

  attr_accessor(*FIELDS)

  validates :provider_id, presence: true
end
