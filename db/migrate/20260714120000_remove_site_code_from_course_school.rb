# frozen_string_literal: true

class RemoveSiteCodeFromCourseSchool < ActiveRecord::Migration[8.1]
  def change
    remove_column :course_school, :site_code, :text
  end
end
