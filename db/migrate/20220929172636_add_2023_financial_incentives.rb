class Add2023FinancialIncentives < ActiveRecord::Migration[7.0]
  def up
    say_with_time "populating 2022 finanical incentive" do
      FinancialIncentive.destroy_all

      year = 2023

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
      Subjects::FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService.new(year:).execute
    end
  end

  def down
    say_with_time "populating 2022 finanical incentive" do
      FinancialIncentive.destroy_all

      [2021, 2022].each do |year|
        Subjects::FinancialIncentiveCreatorService.new(year:).execute
        Subjects::FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService.new(year:).execute
      end
    end
  end
end
