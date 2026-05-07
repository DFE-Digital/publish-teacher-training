# frozen_string_literal: true

class AddYearAndDisplayedToFinancialIncentive < ActiveRecord::Migration[8.1]
  def up
    current_year = (RecruitmentCycle.current&.year || Find::CycleTimetable.current_year).to_i

    change_table :financial_incentive, bulk: true do |t|
      t.integer :year, null: false, default: current_year
      t.boolean :displayed, null: false, default: false
    end

    FinancialIncentive.reset_column_information
    FinancialIncentive.update_all(displayed: true)

    add_index :financial_incentive, %i[subject_id year], unique: true
    add_index :financial_incentive,
              :subject_id,
              unique: true,
              where: "displayed",
              name: "index_financial_incentive_on_displayed_subject_id"
  end

  def down
    remove_index :financial_incentive, name: "index_financial_incentive_on_displayed_subject_id"
    remove_index :financial_incentive, %i[subject_id year]

    change_table :financial_incentive, bulk: true do |t|
      t.remove :displayed
      t.remove :year
    end
  end
end
