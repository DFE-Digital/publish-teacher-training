class AddUkprnToProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :provider, :ukprn, :string
  end
end
