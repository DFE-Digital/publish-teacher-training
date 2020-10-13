class Add2021FinancialIncentives < ActiveRecord::Migration[6.0]
  def up
    say_with_time "populating subjects finanical" do
      Subjects::FinancialIncentiveCreatorService.new(year: 2021).execute
    end
  end

  def down
    FinancialIncentive.connection.truncate :financial_incentive
  end
end
