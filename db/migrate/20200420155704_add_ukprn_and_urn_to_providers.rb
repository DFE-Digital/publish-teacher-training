class AddUkprnAndUrnToProviders < ActiveRecord::Migration[6.0]
  def change
    change_table(:provider, bulk: true) do |t|
      t.column :ukprn, :text, null: true
      t.column :urn, :text, null: true
    end

    add_index :provider, :ukprn
    add_index :provider, :urn
  end
end
