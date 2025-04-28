class RemoveAccreditedProviderEnrichmentsColumn < ActiveRecord::Migration[8.0]
  def change
    remove_column(:provider, :accrediting_provider_enrichments, :jsonb, if_exists: true)
  end
end
