class AddSchoolsValidatedToCourse < ActiveRecord::Migration[8.0]
  def change
    add_column :course, :schools_validated, :boolean
  end
end
