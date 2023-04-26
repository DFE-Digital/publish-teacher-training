# frozen_string_literal: true

module Publish
  module AccreditedProviders
    class SearchService
      include ServicePattern

      DEFAULT_LIMIT = 15

      Result = Struct.new(:providers, :limit, keyword_init: true)

      def initialize(query: nil, limit: DEFAULT_LIMIT)
        @query = StripPunctuationService.call(string: query)
        @limit = limit
      end

      def call
        Result.new(providers:, limit:)
      end

      private

      attr_reader :query, :limit

      def providers
        providers = RecruitmentCycle.current.providers.accredited_provider
        providers = providers.accredited_provider_search(query) if query
        providers = providers.limit(limit) if limit
        providers.reorder(:provider_name)
      end
    end
  end
end
