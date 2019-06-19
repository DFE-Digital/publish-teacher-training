class Add2019RecruitmentCycleToCourses < ActiveRecord::Migration[5.2]
  def up
    recruitment_cycle_2019 = RecruitmentCycle.where(year: '2019').first
    Course.update(recruitment_cycle: recruitment_cycle_2019)
  end

  def down
    Course.update(recruitment_cycle: nil)
  end
end
