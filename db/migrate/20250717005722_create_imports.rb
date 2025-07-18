class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :import do |t|
      t.jsonb :short_summary
      t.jsonb :full_summary
      t.integer :import_type

      t.timestamps
    end
    add_index :import, :import_type
  end
end
