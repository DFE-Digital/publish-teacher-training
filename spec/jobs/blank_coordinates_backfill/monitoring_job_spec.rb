# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlankCoordinatesBackfill::MonitoringJob, type: :job do
  it_behaves_like "a job routed to Solid Queue", queue: "default" do
    let(:solid_queue_job_args) { [1, 1] }
  end

  it "delegates to MonitoringManager" do
    allow(DataHub::BlankCoordinatesBackfill::MonitoringManager).to receive(:check_completion)

    described_class.perform_now(1, 2)

    expect(DataHub::BlankCoordinatesBackfill::MonitoringManager).to have_received(:check_completion).with(1, 2)
  end
end
