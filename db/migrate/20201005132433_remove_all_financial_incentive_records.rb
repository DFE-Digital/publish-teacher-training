class RemoveAllFinancialIncentiveRecords < ActiveRecord::Migration[6.0]
  def up
    say_with_time "removing all finanical incentive" do
      FinancialIncentive.destroy_all
    end
  end

  def down
    say_with_time "populating finanical incentive" do
      Subjects::FinancialIncentiveCreatorService.new(year: 2020).execute
      Subjects::FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService.new(year: 2020).execute
    end
  end
end
