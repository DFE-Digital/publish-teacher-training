# Note: These migrations need to run in the below order
# 1) CreateRecruitmentCycle
#     Add schema change the foreign id as `null`
# 2) CreateRecruitmentCycles
#     Amend the data (backfill)
# 3) Then the relevant course and site migration chains
class CreateRecruitmentCycles < ActiveRecord::Migration[5.2]
  def up
    RecruitmentCycle.create(year: '2019', application_start_date: Date.new(2018, 10, 9))
    RecruitmentCycle.create(year: '2020')
  end

  def down
    RecruitmentCycle.destroy_all
  end
end
