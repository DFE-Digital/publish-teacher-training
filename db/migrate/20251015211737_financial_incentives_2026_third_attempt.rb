class FinancialIncentives2026ThirdAttempt < ActiveRecord::Migration[8.0]
  def up
    say_with_time "adding missing 2026 financial incentives (Latin, Ancient Greek, Ancient Hebrew)" do
      year = 2026

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end

  def down
    say_with_time "reverting to 2025 financial incentives" do
      year = 2025

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end
end
