# frozen_string_literal: true

module Support
  module Providers
    class Filter
      attr_reader :pg_search_method

      def initialize(params:)
        @params = params
        @pg_search_method = :search
      end

      def filters
        return if params.empty? && merged_filters.empty?

        merged_filters
      end

    private

      attr_reader :params

      def merged_filters
        @merged_filters ||= provider_and_course_search
      end

      def text_search
        params.slice(:text_search)
      end

      def provider_and_course_search
        params.slice(:provider_search, :course_search)
      end
    end
  end
end
