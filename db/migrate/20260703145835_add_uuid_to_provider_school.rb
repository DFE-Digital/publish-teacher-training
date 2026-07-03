class AddUuidToProviderSchool < ActiveRecord::Migration[8.1]
  def up
    add_column :provider_school, :uuid, :uuid # rubocop:disable Rails/BulkChangeTable

    change_column_default :provider_school, :uuid, "uuid_generate_v4()"
  end

  def down
    remove_column :provider_school, :uuid
  end
end
