class ChangeProviderColumnsNameAndType < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/BulkChangeTable
  def up
    remove_column :provider, :self_description
    remove_column :provider, :provider_value_proposition

    add_column :provider, :about_us, :text
    add_column :provider, :value_proposition, :text
  end

  def down
    remove_column :provider, :about_us
    remove_column :provider, :value_proposition

    add_column :provider, :self_description, :string
    add_column :provider, :provider_value_proposition, :string
  end
  # rubocop:enable Rails/BulkChangeTable
end
