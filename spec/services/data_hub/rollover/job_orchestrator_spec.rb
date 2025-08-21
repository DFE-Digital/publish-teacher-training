require "rails_helper"
require "sidekiq/testing"

RSpec.describe DataHub::Rollover::JobOrchestrator, type: :service do
  let!(:current_cycle) { RecruitmentCycle.current }
  let!(:next_cycle)    { RecruitmentCycle.next || create(:recruitment_cycle, :next) }
  let!(:providers)     { create_list(:provider, 10, recruitment_cycle: current_cycle) }

  describe "#execute" do
    subject { described_class.new(next_cycle.id).execute }

    around do |example|
      Sidekiq::Testing.inline! do
        example.run
      end
    end

    it "initializes the summary with total_providers" do
      summary = subject
      expect(summary.short_summary["total_providers"]).to eq(10)
      expect(summary.short_summary["providers_rolled_over"]).to eq(0)
    end

    it "schedules provider batch jobs for all providers" do
      expect(RolloverProvidersBatchJob).to receive(:set).twice.and_return(RolloverProvidersBatchJob)
      expect(RolloverProvidersBatchJob).to receive(:perform_later).with(
        providers[0..4].map(&:provider_code),
        next_cycle.id,
        anything,
      )
      expect(RolloverProvidersBatchJob).to receive(:perform_later).with(
        providers[5..].map(&:provider_code),
        next_cycle.id,
        anything,
      )
      subject
    end

    it "schedules the monitoring job" do
      expect(RolloverMonitoringJob).to receive(:perform_in).with(
        kind_of(Numeric),
        anything,
        1,
      )
      subject
    end

    it "logs completion and returns the summary" do
      summary = subject
      expect(summary).to be_a(DataHub::RolloverProcessSummary)
    end

    it "batches providers in id order for job enqueuing" do
      ordered_providers = Provider.order(:id).to_a

      Provider.first.update!(provider_name: "Change provider hopefully order do not change")
      Provider.first.update!(provider_name: "Another provider order do not change")

      expected_first_batch  = ordered_providers.first(5).map(&:provider_code)
      expected_second_batch = ordered_providers.last(5).map(&:provider_code)

      expect(RolloverProvidersBatchJob).to receive(:set).twice.and_return(RolloverProvidersBatchJob)
      expect(RolloverProvidersBatchJob).to receive(:perform_later).ordered.with(
        expected_first_batch, next_cycle.id, anything
      )
      expect(RolloverProvidersBatchJob).to receive(:perform_later).ordered.with(
        expected_second_batch, next_cycle.id, anything
      )

      subject
    end

    context "when scheduling raises an error" do
      it "records failure in summary and re-raises" do
        orchestrator = described_class.new(next_cycle.id)
        allow(orchestrator).to receive(:schedule_monitoring).and_raise("boom")

        expect {
          orchestrator.execute
        }.to raise_error("boom")
        summary = DataHub::RolloverProcessSummary.last

        expect(summary.short_summary).to include(
          "error_class" => "RuntimeError",
          "error_message" => "boom",
        )
      end
    end
  end
end
