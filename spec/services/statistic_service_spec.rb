require "rails_helper"

describe StatisticService do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let!(:previous_recruitment_cycle) { find_or_create(:recruitment_cycle, :previous) }
  let!(:allocation_recruitment_cycle) { find_or_create(:recruitment_cycle, :current_allocation) }
  let!(:previous_allocation_cycle) { find_or_create(:recruitment_cycle, :previous_allocation_cycle) }

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
      expect(AllocationReportingService).to receive(:call).with(recruitment_cycle_scope: allocation_recruitment_cycle)
      subject
    end

    it "calls the rollover reporting service" do
      expect(RolloverReportingService).to receive(:call)
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
      expect(AllocationReportingService).to receive(:call).with(recruitment_cycle_scope: allocation_recruitment_cycle)
      subject
    end

    it "calls the rollover reporting service" do
      expect(RolloverReportingService).to receive(:call)
      subject
    end
  end
end
