# frozen_string_literal: true

class AddStructuredGcseColumnsToCourseTable < ActiveRecord::Migration[6.1]
  def change
    change_table :course, bulk: true do |t|
      t.column :accept_pending_gcse, :boolean, default: false
      t.column :accept_gcse_equivalency, :boolean, default: false
      t.column :accept_english_gcse_equivalency, :boolean, default: false
      t.column :accept_maths_gcse_equivalency, :boolean, default: false
      t.column :accept_science_gcse_equivalency, :boolean, default: false
      t.column :additional_gcse_equivalencies, :string
    end
  end
end
