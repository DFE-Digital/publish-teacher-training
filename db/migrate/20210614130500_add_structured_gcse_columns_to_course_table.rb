class AddStructuredGcseColumnsToCourseTable < ActiveRecord::Migration[6.1]
  def change
    add_column :course, :accept_pending_gcse, :boolean, default: false
    add_column :course, :accept_gcse_equivalency, :boolean, default: false
    add_column :course, :accept_english_gcse_equivalency, :boolean, default: false
    add_column :course, :accept_maths_gcse_equivalency, :boolean, default: false
    add_column :course, :accept_science_gcse_equivalency, :boolean, default: false
    add_column :course, :additional_gcse_equivalencies, :string
  end
end
