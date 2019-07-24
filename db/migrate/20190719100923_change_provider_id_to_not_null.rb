class ChangeProviderIdToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :provider_enrichment, :provider_id, false
  end
end
