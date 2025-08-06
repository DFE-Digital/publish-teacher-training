class ChangeProviderColumnsNameAndType < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/BulkChangeTable
  def up
    rename_column :provider, :self_description, :about_us
    change_column :provider, :about_us, :text
    change_column :provider, :provider_value_proposition, :text
  end

  def down
    rename_column :provider, :about_us, :self_description
    change_column :provider, :self_description, :string
    change_column :provider, :provider_value_proposition, :string
  end
  # rubocop:enable Rails/BulkChangeTable
end
