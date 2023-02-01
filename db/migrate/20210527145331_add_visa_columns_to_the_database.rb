# frozen_string_literal: true

class AddVisaColumnsToTheDatabase < ActiveRecord::Migration[6.1]
  def change
    change_table :provider, bulk: true do |t|
      t.column :can_sponsor_skilled_worker_visa, :boolean
      t.column :can_sponsor_student_visa, :boolean
    end
  end
end
