# frozen_string_literal: true

module Support
  module Allocations
    class Filter
      include ServicePattern

      def initialize(allocations:, filters:)
        @allocations = allocations
        @filters = filters
      end

      def call
        return allocations unless filters

        filter_allocations
      end

    private

      attr_reader :allocations, :filters

      def text_search(allocations, text_search)
        return allocations if text_search.blank?

        allocations.search_by_code_or_name(text_search)
      end

      def filter_allocations
        text_search(allocations, filters[:text_search])
      end
    end
  end
end
