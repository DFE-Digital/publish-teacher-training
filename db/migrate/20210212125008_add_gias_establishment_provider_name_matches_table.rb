class AddGIASEstablishmentProviderNameMatchesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :gias_establishment_provider_name_matches do |t|
      t.integer :establishment_id
      t.integer :provider_id
    end
  end
end
