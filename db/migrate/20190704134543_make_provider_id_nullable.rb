class MakeProviderIdNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :provider_enrichment, :provider_id, true
  end
end
