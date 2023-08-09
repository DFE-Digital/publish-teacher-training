# frozen_string_literal: true

module AccreditedProviders
  class SearchService
    include ServicePattern

    DEFAULT_LIMIT = 15

    Result = Struct.new(:providers, :limit, keyword_init: true)

    def initialize(query: nil, limit: DEFAULT_LIMIT, recruitment_cycle_year: nil)
      @query = StripPunctuationService.call(string: query)
      @limit = limit
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      Result.new(providers:, limit:)
    end

    private

    attr_reader :query, :limit, :recruitment_cycle_year

    def providers
      providers = RecruitmentCycle.find_by(year: recruitment_cycle_year).providers.accredited_provider
      providers = providers.accredited_provider_search(query) if query
      providers = providers.limit(limit) if limit
      providers.reorder(:provider_name)
    end
  end
end
