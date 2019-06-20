class Add2019RecruitmentCycleToSites < ActiveRecord::Migration[5.2]
  def up
    current_recruitment_cycle = RecruitmentCycle.where(year: '2019').first
    Site.update(recruitment_cycle: current_recruitment_cycle)
  end

  def down
    Site.update(recruitment_cycle: nil)
  end
end
