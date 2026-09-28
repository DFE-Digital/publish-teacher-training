# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverMonitoringJob, type: :job do
  let(:process_summary) { create(:rollover_process_summary) }

  it_behaves_like "a job routed to Solid Queue", queue: "default" do
    let(:solid_queue_job_args) { [1, 1] }
  end

  describe "#perform" do
    it "delegates to MonitoringManager" do
      expect(DataHub::Rollover::MonitoringManager).to receive(:check_completion).with(process_summary.id, 1)

      described_class.perform_now(process_summary.id, 1)
    end
  end
end
