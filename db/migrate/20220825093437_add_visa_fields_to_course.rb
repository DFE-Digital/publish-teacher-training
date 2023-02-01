# frozen_string_literal: true

class AddVisaFieldsToCourse < ActiveRecord::Migration[7.0]
  def change
    change_table :course, bulk: true do |t|
      t.column :can_sponsor_skilled_worker_visa, :boolean, default: false
      t.column :can_sponsor_student_visa, :boolean, default: false
      t.index :can_sponsor_skilled_worker_visa
      t.index :can_sponsor_student_visa
    end
  end
end
