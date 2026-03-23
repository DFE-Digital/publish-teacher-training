class RenameFirstPublishedDatetimeToFirstPublishedAtOnCourses < ActiveRecord::Migration[8.0]
  def change
    rename_column :course, :first_published_datetime, :first_published_at
  end
end
