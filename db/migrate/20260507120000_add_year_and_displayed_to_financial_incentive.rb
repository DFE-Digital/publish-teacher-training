# frozen_string_literal: true

class AddYearAndDisplayedToFinancialIncentive < ActiveRecord::Migration[8.1]
  def up
    guard_against_duplicate_subject_incentives!(
      "Cannot add financial incentive uniqueness constraints",
    )

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
    guard_against_duplicate_subject_incentives!(
      "Cannot rollback financial incentive year and display columns",
    )

    remove_index :financial_incentive, name: "index_financial_incentive_on_displayed_subject_id"
    remove_index :financial_incentive, %i[subject_id year]

    change_table :financial_incentive, bulk: true do |t|
      t.remove :displayed
      t.remove :year
    end
  end

private

  def guard_against_duplicate_subject_incentives!(message)
    duplicates = select_all(<<~SQL.squish)
      SELECT subject_id, COUNT(*) AS financial_incentive_count
      FROM financial_incentive
      WHERE subject_id IS NOT NULL
      GROUP BY subject_id
      HAVING COUNT(*) > 1
      ORDER BY financial_incentive_count DESC, subject_id
      LIMIT 10
    SQL

    return if duplicates.rows.empty?

    duplicate_details = duplicates.map do |duplicate|
      "subject_id #{duplicate['subject_id']} has #{duplicate['financial_incentive_count']} rows"
    end
    duplicate_details = duplicate_details.join("; ")

    raise ActiveRecord::MigrationError,
          "#{message}: duplicate financial_incentive records already exist. #{duplicate_details}. " \
          "Resolve these records before running this migration."
  end
end
