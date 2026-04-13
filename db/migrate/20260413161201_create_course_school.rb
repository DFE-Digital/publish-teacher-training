# frozen_string_literal: true

class CreateCourseSchool < ActiveRecord::Migration[8.1]
  def change
    create_table :course_school do |t|
      t.integer :course_id, null: false
      t.bigint :gias_school_id, null: false
      t.text :site_code, null: false
      t.timestamps
    end

    add_foreign_key :course_school, :course
    add_foreign_key :course_school, :gias_school

    add_index :course_school, :gias_school_id
    add_index :course_school, %i[course_id gias_school_id site_code],
              unique: true,
              name: "index_course_school_unique"
  end
end
