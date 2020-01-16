class SubjectFinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService
  def initialize(financial_incentive: FinancialIncentive)
    @financial_incentive = financial_incentive
  end

  def execute
    subject_with_subject_knowledge_enhancement_course_available = ["Primary with mathematics", "Biology", "Computing", "English", "Design and technology", "Geography", "Chemistry", "Mathematics", "Physics", "French", "German", "Spanish", "Italian", "Japanese", "Mandarin", "Russian", "Modern languages (other)", "Religious education"]

    financial_incentives = @financial_incentive.joins(:subject).where(subject: { subject_name: subject_with_subject_knowledge_enhancement_course_available })
    financial_incentives.update_all(subject_knowledge_enhancement_course_available: true)
  end
end
