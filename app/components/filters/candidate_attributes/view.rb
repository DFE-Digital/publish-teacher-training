# frozen_string_literal: true

module Filters
  module CandidateAttributes
    class View < ViewComponent::Base
      attr_accessor :filters

      def initialize(filters:)
        @filters = filters
        super
      end
    end
  end
end
