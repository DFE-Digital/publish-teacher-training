module Subjects
  class FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService
    def initialize(year:, financial_incentive: FinancialIncentive)
      @financial_incentive = financial_incentive
      @year = year
    end

    def subject_with_subject_knowledge_enhancement_course_available
      subject_with_subject_knowledge_enhancement_course_available = {
        2020 => ["Primary with mathematics", "Biology", "Computing", "English", "Design and technology", "Geography", "Chemistry", "Mathematics", "Physics", "French", "German", "Spanish", "Italian", "Japanese", "Mandarin", "Russian", "Modern languages (other)", "Religious education"],
      }
      subject_with_subject_knowledge_enhancement_course_available[@year]
    end

    def execute
      financial_incentives = @financial_incentive.joins(:subject).where(subject: { subject_name: subject_with_subject_knowledge_enhancement_course_available })
      financial_incentives.update_all(subject_knowledge_enhancement_course_available: true)
    end
  end
end
