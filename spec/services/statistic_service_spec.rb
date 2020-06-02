describe StatisticService do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let!(:previous_recruitment_cycle) { find_or_create(:recruitment_cycle, :previous) }

  describe "#reporting" do
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

    it "calls the allocation reporting service" do
      expect(AllocationReportingService).to receive(:call).with(recruitment_cycle_scope: recruitment_cycle)
      subject
    end
  end

  describe "#save" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }

    subject { described_class.save }

    it "saves an statistic" do
      expect { subject }.to change { Statistic.all.size }.by(1)
    end

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

    it "calls the allocation reporting service" do
      expect(AllocationReportingService).to receive(:call).with(recruitment_cycle_scope: recruitment_cycle)
      subject
    end
  end
end
