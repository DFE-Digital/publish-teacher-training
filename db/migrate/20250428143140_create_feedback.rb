class CreateFeedback < ActiveRecord::Migration[8.0]
  def change
    create_table :feedback do |t|
      t.string :ease_of_use
      t.text :experience

      t.timestamps
    end
  end
end
