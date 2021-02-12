class AddGIASEstablishmentSitePostcodeMatchesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :gias_establishment_site_postcode_matches do |t|
      t.integer :establishment_id
      t.integer :site_id
    end
  end
end
