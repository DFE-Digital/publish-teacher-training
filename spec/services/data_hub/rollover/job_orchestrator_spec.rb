# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Rollover::JobOrchestrator, type: :service do
  let(:current_cycle) { RecruitmentCycle.current }
  let(:next_cycle) { RecruitmentCycle.next || create(:recruitment_cycle, :next) }
  let!(:provider_one) { create(:provider, provider_code: "ABC", recruitment_cycle: current_cycle) }
  let!(:provider_two) { create(:provider, provider_code: "DEF", recruitment_cycle: current_cycle) }

  describe ".start_rollover" do
    it "creates process summary and schedules jobs correctly" do
      expect(RolloverProviderJob).to receive(:perform_at).twice
      expect(RolloverMonitoringJob).to receive(:perform_in).with(125.minutes, anything, 1)

      process_summary = described_class.start_rollover(next_cycle.id)

      expect(process_summary).to be_a(DataHub::RolloverProcessSummary)
      expect(process_summary.short_summary["total_providers"]).to eq(2)
      expect(process_summary.status).to eq("started")
    end

    it "handles errors gracefully" do
      allow(BatchDelivery).to receive(:new).and_raise(StandardError, "DB Error")

      expect {
        described_class.start_rollover(next_cycle.id)
      }.to raise_error(StandardError, "DB Error")

      process_summary = DataHub::RolloverProcessSummary.last
      expect(process_summary.status).to eq("failed")
    end
  end
end
