class AddForeignKeyToSiteAndRecruitmentCycle < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :site, :recruitment_cycle
  end
end
