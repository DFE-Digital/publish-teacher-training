# frozen_string_literal: true

module Filters
  class SubjectAttributes < ViewComponent::Base
    attr_accessor :filters

    def initialize(filters:)
      super()
      @filters = filters
    end
  end
end
