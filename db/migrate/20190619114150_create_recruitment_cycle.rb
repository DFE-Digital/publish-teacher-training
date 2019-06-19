class CreateRecruitmentCycle < ActiveRecord::Migration[5.2]
  def change
    create_table :recruitment_cycle do |t|
      t.string :year
      t.date :application_start_date
      t.date :application_end_date

      t.timestamps
    end
  end
end
