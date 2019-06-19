class CreateRecruitmentCycles < ActiveRecord::Migration[5.2]
  def up
    RecruitmentCycle.create(year: '2019', application_start_date: Date.new(2018, 10, 9))
    RecruitmentCycle.create(year: '2020')
  end

  def down
    RecruitmentCycle.destroy_all
  end
end
