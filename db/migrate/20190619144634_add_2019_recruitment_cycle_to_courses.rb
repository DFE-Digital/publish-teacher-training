# Note: These migrations need to run in the below order
# 1) AddRecruitmentCycleToCourse
#     Add schema change the foreign id as `null`
# 2) Add2019RecruitmentCycleToCourses
#     Amend the data (backfill)
# 3) SetRecruitmentCycleToNotNull
#     Amend schema the foreign id as `not null`
class Add2019RecruitmentCycleToCourses < ActiveRecord::Migration[5.2]
  def up
    current_recruitment_cycle = RecruitmentCycle.where(year: "2019").first
    Course.connection.update <<~EOSQL
      UPDATE course SET recruitment_cycle_id=#{current_recruitment_cycle.id}
    EOSQL
  end

  def down
    Course.connection.update <<~EOSQL
      UPDATE course SET recruitment_cycle_id=NULL
    EOSQL
  end
end
