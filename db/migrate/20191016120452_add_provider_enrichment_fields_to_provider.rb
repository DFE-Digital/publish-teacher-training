class AddProviderEnrichmentFieldsToProvider < ActiveRecord::Migration[6.0]
  def change
    add_column :provider, :train_with_us, :text
    add_column :provider, :train_with_disability, :text
    add_column :provider, :accrediting_provider_enrichments, :jsonb
    rename_column :provider, :url, :website
  end
end
