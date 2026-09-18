# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Rollover::MonitoringManager, type: :service do
  let(:process_summary) { create(:rollover_process_summary) }

  before do
    process_summary.initialize_summary!
    process_summary.set_total_providers(3)
  end

  describe ".check_completion" do
    context "when all providers are processed" do
      before do
        process_summary.add_provider_result(provider_code: "ABC", status: :rolled_over, details: {})
        process_summary.add_provider_result(provider_code: "DEF", status: :skipped, details: {})
        process_summary.add_provider_result(provider_code: "GHI", status: :errored, details: {})
      end

      it "finishes the process" do
        described_class.check_completion(process_summary.id, 1)

        process_summary.reload
        expect(process_summary.status).to eq("finished")
        expect(process_summary.finished_at).to be_present
      end
    end

    context "when providers are still processing" do
      before do
        process_summary.add_provider_result(provider_code: "ABC", status: :rolled_over, details: {})
      end

      it "schedules next check when under attempt limit" do
        expect {
          described_class.check_completion(process_summary.id, 1)
        }.to have_enqueued_job(RolloverMonitoringJob)
          .with(process_summary.id, 2)
          .at(be_within(1.second).of(5.minutes.from_now))

        process_summary.reload
        expect(process_summary.status).to eq("started")
      end

      it "handles timeout when attempt limit reached" do
        expect {
          described_class.check_completion(process_summary.id, 5)
        }.not_to have_enqueued_job(RolloverMonitoringJob)

        process_summary.reload
        expect(process_summary.status).to eq("finished")
        expect(process_summary.full_summary["monitoring_timeout"]).to be_present
      end
    end

    context "when process is already finished" do
      before do
        process_summary.update!(status: "finished", finished_at: Time.current)
      end

      it "does not process further" do
        expect {
          described_class.check_completion(process_summary.id, 1)
        }.not_to have_enqueued_job(RolloverMonitoringJob)
      end
    end
  end
end
