class MakeProviderNameNotNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :provider, :provider_name, false
  end
end
