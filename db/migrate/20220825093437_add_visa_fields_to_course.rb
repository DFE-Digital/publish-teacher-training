class AddVisaFieldsToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :course, :can_sponsor_skilled_worker_visa, :boolean, default: false
    add_column :course, :can_sponsor_student_visa, :boolean, default: false
    add_index :course, :can_sponsor_skilled_worker_visa
    add_index :course, :can_sponsor_student_visa
  end
end
