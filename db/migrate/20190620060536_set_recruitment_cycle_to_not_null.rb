class SetRecruitmentCycleToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :course, :recruitment_cycle_id, false
  end
end
