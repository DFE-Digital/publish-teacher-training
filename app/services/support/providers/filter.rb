# frozen_string_literal: true

module Support
  module Providers
    class Filter
      include ServicePattern

      def initialize(providers:, filters:)
        @providers = providers
        @filters = filters
      end

      def call
        return providers unless filters

        filter_trainees
      end

    private

      attr_reader :providers, :filters

      def text_search(providers, text_search)
        return providers if text_search.blank?

        providers.search_by_code_or_name(text_search)
      end

      def filter_trainees
        text_search(providers, filters[:text_search])
      end
    end
  end
end
