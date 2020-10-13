class AddMissing2021FinancialIncentives < ActiveRecord::Migration[6.0]
  def up
    say_with_time "populating subjects finanical" do
      Subjects::FinancialIncentiveCreatorService.new(year: 2021).execute
    end
  end

  def down
    # There is no need to go back.
  end
end
