class AddAvailableForSupportUsersDateToRecruitmentCycle < ActiveRecord::Migration[8.0]
  def change
    add_column :recruitment_cycle, :available_for_support_users_from, :date
  end
end
