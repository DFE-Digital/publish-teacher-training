# frozen_string_literal: true

class CreateSubjectGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :subject_group do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
