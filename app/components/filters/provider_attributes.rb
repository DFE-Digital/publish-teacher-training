# frozen_string_literal: true

module Filters
  class ProviderAttributes < ViewComponent::Base
    attr_accessor :filters

    def initialize(filters:)
      @filters = filters
      super
    end
  end
end
