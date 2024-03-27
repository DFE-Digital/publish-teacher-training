# frozen_string_literal: true

class AddSubjectKnowledgeEnhancementAvailableToFinancialIncentive < ActiveRecord::Migration[6.0]
  def change
    add_column :financial_incentive, :subject_knowledge_enhancement_course_available, :boolean, null: false, default: false
  end
end
