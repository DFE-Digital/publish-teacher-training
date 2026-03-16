class AddFirstPublishedDateToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :course, :first_published_date, :date
  end
end

