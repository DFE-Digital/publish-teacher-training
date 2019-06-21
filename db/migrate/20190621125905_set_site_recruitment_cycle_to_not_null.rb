class SetSiteRecruitmentCycleToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :site, :recruitment_cycle_id, false
  end
end
