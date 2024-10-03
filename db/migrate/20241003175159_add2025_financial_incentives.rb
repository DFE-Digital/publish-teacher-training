class Add2025FinancialIncentives < ActiveRecord::Migration[7.2]
  def up
    say_with_time 'populating 2025 financial incentives' do
      FinancialIncentive.destroy_all

      year = 2025

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end

  def down
    say_with_time 'populating 2024 financial incentives' do
      FinancialIncentive.destroy_all

      year = 2024

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end
end
