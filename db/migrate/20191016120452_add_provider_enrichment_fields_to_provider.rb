class AddProviderEnrichmentFieldsToProvider < ActiveRecord::Migration[6.0]
  def change
    change_table :provider, bulk: true do |t|
      t.text :train_with_us
      t.text :train_with_disability
      t.jsonb :accrediting_provider_enrichments
      t.rename :url, :website
    end
  end
end
