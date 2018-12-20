class ProviderEnrichment < ApplicationRecord
  self.table_name = "provider_enrichment"
  self.primary_key = "provider_code"

  enum status: { draft: 0, published: 1 }

  belongs_to :provider, foreign_key: :provider_code, primary_key: :provider_code
end
