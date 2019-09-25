# Note: These migrations need to run in the below order
# 1) AddRecruitmentCycleToSite
#     Add schema change the foreign id as `null`
# 2) Add2019RecruitmentCycleToSites
#     Amend the data (backfill)
# 3) SetSiteRecruitmentCycleToNotNull
#     Amend schema the foreign id as `not null`
class Add2019RecruitmentCycleToSites < ActiveRecord::Migration[5.2]
  def up
    current_recruitment_cycle = RecruitmentCycle.where(year: "2019").first
    Site.connection.update <<~EOSQL
      UPDATE site SET recruitment_cycle_id=#{current_recruitment_cycle.id}
    EOSQL
  end

  def down
    Site.connection.update <<~EOSQL
      UPDATE site SET recruitment_cycle_id=NULL
    EOSQL
  end
end
