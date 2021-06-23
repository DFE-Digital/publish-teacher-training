class RemoveStructuredGcseColumnsFromCourseTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :course, :accept_pending_gcse, :boolean
    remove_column :course, :accept_gcse_equivalency, :boolean
    remove_column :course, :accept_english_gcse_equivalency, :boolean
    remove_column :course, :accept_maths_gcse_equivalency, :boolean
    remove_column :course, :accept_science_gcse_equivalency, :boolean
    remove_column :course, :additional_gcse_equivalencies, :string
    add_column :course, :accept_pending_gcse, :boolean
    add_column :course, :accept_gcse_equivalency, :boolean
    add_column :course, :accept_english_gcse_equivalency, :boolean
    add_column :course, :accept_maths_gcse_equivalency, :boolean
    add_column :course, :accept_science_gcse_equivalency, :boolean
    add_column :course, :additional_gcse_equivalencies, :string
  end
end
