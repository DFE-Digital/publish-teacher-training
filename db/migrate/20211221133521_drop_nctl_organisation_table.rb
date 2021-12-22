class DropNctlOrganisationTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :nctl_organisation do |t|
      t.text :name
      t.text :nctl_id
      t.integer :organisation_id
      t.remove_index(name: "IX_nctl_organisation_organisation_id")
      t.remove_foreign_key(column: :organisation_id)
    end
  end
end
