class AddNonUkEligibilityToFinancialIncentive < ActiveRecord::Migration[8.0]
  def change
    change_table :financial_incentive, bulk: true do |t|
      t.boolean :non_uk_bursary_eligible, default: false, null: false
      t.boolean :non_uk_scholarship_eligible, default: false, null: false
    end
  end
end
