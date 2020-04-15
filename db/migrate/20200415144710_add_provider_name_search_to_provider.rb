class AddProviderNameSearchToProvider < ActiveRecord::Migration[6.0]
  def change
    add_column :provider, :provider_name_search, :string
  end
end
