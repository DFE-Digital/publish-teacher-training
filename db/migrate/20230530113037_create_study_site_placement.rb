# frozen_string_literal: true

class CreateStudySitePlacement < ActiveRecord::Migration[7.0]
  def change
    create_table :study_site_placement do |t|
      t.references :course, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end
  end
end
