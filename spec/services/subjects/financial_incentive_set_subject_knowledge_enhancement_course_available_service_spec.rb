describe Subjects::FinancialIncentiveSetSubjectKnowledgeEnhancementCourseAvailableService do
  let(:financial_incentive_spy) { spy }
  let(:financial_incentives_records_spy) { spy }

  let(:service) do
    described_class.new(
      financial_incentive: financial_incentive_spy,
    )
  end

  before do
    allow(financial_incentive_spy).to receive(:where).and_return financial_incentives_records_spy
    allow(financial_incentives_records_spy).to receive(:update_all)
  end

  it "sets the subject knowledge enhancement course available for existing financial incentive " do
    service.execute
    expect(financial_incentive_spy).to have_received(:where)
      .with(subject: { subject_name: ["Primary with mathematics", "Biology", "Computing", "English", "Design and technology", "Geography", "Chemistry", "Mathematics", "Physics", "French", "German", "Spanish", "Italian", "Japanese", "Mandarin", "Russian", "Modern languages (other)", "Religious education"] })
      .exactly(1).times
    expect(financial_incentives_records_spy).to have_received(:update_all)
      .with(subject_knowledge_enhancement_course_available: true)
      .exactly(1).times
  end
end
