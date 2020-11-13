class AddUuidToCourse < ActiveRecord::Migration[6.0]
  def up
    enable_extension "uuid-ossp" unless extension_enabled?("uuid-ossp")

    add_column :course, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    add_index :course, :uuid, unique: true, name: "index_courses_unique_uuid"
  end

  def down
    # There is no going back
  end
end
