class DropAccreditingProviderIdFromCourse < ActiveRecord::Migration[6.0]
  def up
    remove_column :course, :accrediting_provider_id
  end

  def down
    add_column :course, :accrediting_provider_id
  end
end
