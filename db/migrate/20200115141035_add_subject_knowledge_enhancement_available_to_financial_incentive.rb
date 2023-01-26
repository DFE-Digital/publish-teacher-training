# frozen_string_literal: true

class AddSubjectKnowledgeEnhancementAvailableToFinancialIncentive < ActiveRecord::Migration[6.0]
  def change
    add_column :financial_incentive, :subject_knowledge_enhancement_course_available, :boolean, null: false, default: false

    say_with_time 'populating finanical incentive subject knowledge enhancement course available' do
      Subjects::FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService.new(year: 2020).execute
    end
  end
end
