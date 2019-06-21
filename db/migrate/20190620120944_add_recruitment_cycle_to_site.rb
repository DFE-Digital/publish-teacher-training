class AddRecruitmentCycleToSite < ActiveRecord::Migration[5.2]
  def change
    add_reference :site, :recruitment_cycle, index: true, type: :int
  end
end
