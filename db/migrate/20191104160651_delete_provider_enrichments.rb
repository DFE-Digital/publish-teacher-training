class DeleteProviderEnrichments < ActiveRecord::Migration[6.0]
  def change
    drop_table :provider_enrichment
  end
end
