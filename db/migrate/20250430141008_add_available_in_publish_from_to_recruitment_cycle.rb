class AddAvailableInPublishFromToRecruitmentCycle < ActiveRecord::Migration[8.0]
  def change
    add_column :recruitment_cycle, :available_in_publish_from, :date

    reversible do |dir|
      dir.up do
        RecruitmentCycle.reset_column_information
        RecruitmentCycle.where(year: "2025").update_all(available_in_publish_from: Date.new(2024, 7, 16))
        RecruitmentCycle.where(year: "2024").update_all(available_in_publish_from: Date.new(2023, 7, 13))
        RecruitmentCycle.where(year: "2023").update_all(available_in_publish_from: Date.new(2022, 7, 7))
        RecruitmentCycle.where(year: "2022").update_all(available_in_publish_from: Date.new(2021, 7, 6))
        RecruitmentCycle.where(year: "2021").update_all(available_in_publish_from: Date.new(2020, 7, 5))
        RecruitmentCycle.where(year: "2020").update_all(available_in_publish_from: Date.new(2019, 7, 1))
        RecruitmentCycle.where(year: "2019").update_all(available_in_publish_from: Date.new(2018, 7, 1))
      end
    end
  end
end
