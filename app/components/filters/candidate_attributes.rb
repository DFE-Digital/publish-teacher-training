# frozen_string_literal: true

module Filters
  class CandidateAttributes < ViewComponent::Base
    attr_accessor :filters

    def initialize(filters:)
      @filters = filters
      super
    end
  end
end
