# frozen_string_literal: true

class ProviderSuggestion
  include ActiveModel::Model

  attr_accessor :id, :name, :code, :value
end
