class RemoveSubjectKnowledgeEnhancementCourseAvailableFromFinancialIncentive < ActiveRecord::Migration[7.0]
  def change
    remove_column :financial_incentive, :subject_knowledge_enhancement_course_available
  end
end
