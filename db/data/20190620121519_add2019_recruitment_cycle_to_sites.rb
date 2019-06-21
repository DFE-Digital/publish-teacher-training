class Add2019RecruitmentCycleToSites < ActiveRecord::Migration[5.2]
  def up
    current_recruitment_cycle = RecruitmentCycle.where(year: '2019').first
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
