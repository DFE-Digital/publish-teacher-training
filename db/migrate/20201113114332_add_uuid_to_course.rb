class AddUuidToCourse < ActiveRecord::Migration[6.0]
  def change
    add_column :course, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    add_index :course, :uuid, unique: true, name: "index_courses_unique_uuid"
  end
end
