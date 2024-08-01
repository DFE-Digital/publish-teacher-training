# frozen_string_literal: true

class AddCourseTypeToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :course_type, :string, default: 'postgraduate', null: false
  end
end
