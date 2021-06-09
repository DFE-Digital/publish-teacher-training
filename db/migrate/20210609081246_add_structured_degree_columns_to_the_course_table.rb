class AddStructuredDegreeColumnsToTheCourseTable < ActiveRecord::Migration[6.1]
  def change
    add_column :course, :degree_grade, :integer
    add_column :course, :additional_degree_subject_requirements, :boolean
    add_column :course, :degree_subject_requirements, :string
  end
end
