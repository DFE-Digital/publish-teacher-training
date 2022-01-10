class AddAncientLanguages < ActiveRecord::Migration[6.1]
  def up
    Subjects::CreatorService.new.execute
    Subjects::FinancialIncentiveCreatorService.new(year: 2022).execute
  end

  def down
    # There is no need to go back.
  end
end
