class AddChangedAtToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :course, :changed_at, :datetime, default: -> { "timezone('utc'::text, now())" }, null: false
  end
end
