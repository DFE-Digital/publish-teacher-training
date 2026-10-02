# frozen_string_literal: true

class RemoveSchoolsValidatedFromCourse < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :course, :schools_validated, :boolean }
  end
end
