class CreateBanner < ActiveRecord::Migration[8.1]
  def change
    create_table :banner do |t|
      t.string :name, null: false
      t.string :heading
      t.text :body, null: false
      t.datetime :published_at, null: false
      t.datetime :expired_at
      t.boolean :display_on_find, default: false, null: false
      t.boolean :display_on_publish, default: false, null: false
      t.boolean :display_on_support, default: false, null: false

      t.timestamps
    end
  end
end
