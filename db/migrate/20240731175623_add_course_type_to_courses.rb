# frozen_string_literal: true

class AddCourseTypeToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :course_type, :integer, default: 0, null: false
  end
end
