class AddForeignKeyToProviderAndProviderEnrichment < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :provider_enrichment, :provider
  end
end
