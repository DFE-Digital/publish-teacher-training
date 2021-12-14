# frozen_string_literal: true

module Support
  module Allocations
    class Filter
      attr_reader :pg_search_method

      def initialize(params:)
        @params = params
        @pg_search_method = :provider_search
      end

      def filters
        return if params.empty? && merged_filters.empty?

        merged_filters
      end

    private

      attr_reader :params

      def merged_filters
        @merged_filters ||= params.slice(:text_search)
      end
    end
  end
end
