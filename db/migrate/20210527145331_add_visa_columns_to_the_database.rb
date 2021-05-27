class AddVisaColumnsToTheDatabase < ActiveRecord::Migration[6.1]
  def change
    add_column :provider, :can_sponsor_skilled_worker_visa, :boolean
    add_column :provider, :can_sponsor_student_visa, :boolean
  end
end
