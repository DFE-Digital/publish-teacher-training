class Add2019RecruitmentCycleToCourses < ActiveRecord::Migration[5.2]
  def up
    current_recruitment_cycle = RecruitmentCycle.where(year: '2019').first
    Course.update(recruitment_cycle: current_recruitment_cycle)
  end

  def down
    Course.update(recruitment_cycle: nil)
  end
end
