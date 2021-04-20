class AddUrnToProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :provider, :urn, :string
  end
end
