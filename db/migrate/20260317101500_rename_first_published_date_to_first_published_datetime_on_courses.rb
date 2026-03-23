class RenameFirstPublishedDateToFirstPublishedDatetimeOnCourses < ActiveRecord::Migration[8.0]
  def up
    rename_column :course, :first_published_date, :first_published_datetime
    change_column :course, :first_published_datetime, :datetime
  end

  def down
    change_column :course, :first_published_datetime, :date
    rename_column :course, :first_published_datetime, :first_published_date
  end
end
