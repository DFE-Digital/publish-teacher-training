class AddFinancialIncentiveToSubjects < ActiveRecord::Migration[6.0]
  def up
    say_with_time "populating subjects finanical" do
      Subjects::FinancialIncentiveCreatorService.new.execute
    end
  end

  def down
    FinancialIncentive.connection.truncate :financial_incentive
  end
end
