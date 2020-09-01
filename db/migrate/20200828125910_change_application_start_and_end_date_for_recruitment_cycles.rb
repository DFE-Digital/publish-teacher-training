class ChangeApplicationStartAndEndDateForRecruitmentCycles < ActiveRecord::Migration[6.0]
  def up
    recruitment_cycle = RecruitmentCycle.find_by(year: "2021")
    return if recruitment_cycle.nil?

    recruitment_cycle.application_start_date = Date.new(2020, 10, 13)
    recruitment_cycle.application_end_date = Date.new(2021, 10, 3)
    recruitment_cycle.save!
  end

  def down
    recruitment_cycle = RecruitmentCycle.find_by(year: "2021")
    return if recruitment_cycle.nil?

    recruitment_cycle.application_start_date = Date.new(2020, 10, 8)
    recruitment_cycle.application_end_date = Date.new(2021, 9, 30)
    recruitment_cycle.save!
  end
end
