class AddForeignKeyToCourseAndRecruitmentCycle < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :course, :recruitment_cycle
  end
end
