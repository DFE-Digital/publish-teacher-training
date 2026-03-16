class AddIndexToCoursesFirstPublishedDate < ActiveRecord::Migration[8.0]
  def change
    add_index :course, :first_published_date
  end
end
