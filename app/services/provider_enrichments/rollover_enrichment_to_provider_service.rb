module ProviderEnrichments
  class RolloverEnrichmentToProviderService
    def execute(enrichment:, new_provider:)
      new_enrichment = enrichment.dup
      new_enrichment.last_published_at = nil
      new_enrichment.provider = new_provider
      new_enrichment.rolled_over!
    end
  end
end
