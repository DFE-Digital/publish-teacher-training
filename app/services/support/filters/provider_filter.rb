# frozen_string_literal: true

module Support
  module Filters
    class ProviderFilter
      def initialize(params:)
        @params = params
      end

      def filters
        return if params.empty? && merged_filters.empty?

        merged_filters
      end

    private

      attr_reader :params

      def merged_filters
        @merged_filters ||= params.slice(:provider_search, :course_search)
      end
    end
  end
end
