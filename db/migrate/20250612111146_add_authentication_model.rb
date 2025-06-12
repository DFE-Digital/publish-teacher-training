class AddAuthenticationModel < ActiveRecord::Migration[8.0]
  def change
    create_table :authentication do |t|
      t.integer :provider, null: false
      t.string :subject_key, null: false, index: true
      t.references :authenticable, null: false, polymorphic: true

      t.timestamps
    end
  end
end
