class CreateBanner < ActiveRecord::Migration[8.1]
  def change
    create_table :banner do |t|
      t.string :name, null: false
      t.string :title
      t.integer :title_heading_level
      t.boolean :success_styling
      t.string :heading
      t.text :body
      t.datetime :published_at
      t.datetime :expired_at
      t.boolean :display_on_find
      t.boolean :display_on_publish
      t.boolean :display_on_support

      t.timestamps
    end
  end
end
