# frozen_string_literal: true

class RemoveCourseTypeFromCourse < ActiveRecord::Migration[7.2]
  def change
    remove_column :course, :course_type, :string
  end
end
