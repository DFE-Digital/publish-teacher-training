class CreateAllocation < ActiveRecord::Migration[6.0]
  def change
    create_table :allocation do |t|
      t.references :provider, foreign_key: true
      t.references :accredited_body, foreign_key: { to_table: :provider }
      t.integer :number_of_places
      t.timestamps
    end
  end
end
