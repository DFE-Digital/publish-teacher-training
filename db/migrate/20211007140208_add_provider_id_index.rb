class AddProviderIdIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :course, :provider_id
  end
end
