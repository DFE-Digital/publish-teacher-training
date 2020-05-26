describe StatisticService do
  describe "#reporting" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }

    subject { described_class.reporting(recruitment_cycle: recruitment_cycle) }

    it "calls the provider reporting service" do
      expect(ProviderReportingService).to receive(:call).with(providers_scope: recruitment_cycle.providers)
      subject
    end

    it "calls the course reporting service" do
      expect(CourseReportingService).to receive(:call).with(courses_scope: recruitment_cycle.courses)
      subject
    end

    it "calls the publish reporting service" do
      expect(PublishReportingService).to receive(:call).with(recruitment_cycle_scope: recruitment_cycle)
      subject
    end
  end
end
