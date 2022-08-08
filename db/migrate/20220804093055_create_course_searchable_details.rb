class CreateCourseSearchableDetails < ActiveRecord::Migration[7.0]
  def change
    create_view :course_searchable_details, materialized: true
  end
end
