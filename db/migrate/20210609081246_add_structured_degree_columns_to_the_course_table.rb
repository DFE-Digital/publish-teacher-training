# frozen_string_literal: true

class AddStructuredDegreeColumnsToTheCourseTable < ActiveRecord::Migration[6.1]
  def change
    change_table :course, bulk: true do |t|
      t.column :degree_grade, :integer
      t.column :additional_degree_subject_requirements, :boolean
      t.column :degree_subject_requirements, :string
    end
  end
end
