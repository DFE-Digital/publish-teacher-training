class AddProviderRefToProviderEnrichment < ActiveRecord::Migration[5.2]
  def up
    add_reference :provider_enrichment, :provider, index: true, type: :int

    execute <<-SQL
    UPDATE provider_enrichment
    SET    provider_id =
           (
                  SELECT provider.id
                  FROM   provider
                  WHERE  provider_enrichment.provider_code    = provider.provider_code)
    SQL

    change_column_null :provider_enrichment, :provider_id, false
  end

  def down
    remove_reference :provider_enrichment, :provider
  end
end
