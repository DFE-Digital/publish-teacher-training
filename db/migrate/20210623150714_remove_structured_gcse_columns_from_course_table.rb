# frozen_string_literal: true

class RemoveStructuredGcseColumnsFromCourseTable < ActiveRecord::Migration[6.1]
  def change
    change_table :course, bulk: true do |t|
      t.remove :accept_pending_gcse, type: :boolean
      t.remove :accept_gcse_equivalency, type: :boolean
      t.remove :accept_english_gcse_equivalency, type: :boolean
      t.remove :accept_maths_gcse_equivalency, type: :boolean
      t.remove :accept_science_gcse_equivalency, type: :boolean
      t.remove :additional_gcse_equivalencies, type: :string
      t.column :accept_pending_gcse, :boolean
      t.column :accept_gcse_equivalency, :boolean
      t.column :accept_english_gcse_equivalency, :boolean
      t.column :accept_maths_gcse_equivalency, :boolean
      t.column :accept_science_gcse_equivalency, :boolean
      t.column :additional_gcse_equivalencies, :string
    end
  end
end
