class AddPublishWithoutSchoolsAllowedToCourse < ActiveRecord::Migration[8.0]
  def change
    add_column :course, :publish_without_schools_allowed, :boolean, null: false, default: false
  end
end
