# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlankCoordinatesBackfill::BackfillJob, type: :job do
  it_behaves_like "a job routed to Solid Queue", queue: "default" do
    let(:solid_queue_job_args) { [2026] }
  end

  it "delegates to JobOrchestrator" do
    allow(DataHub::BlankCoordinatesBackfill::JobOrchestrator).to receive(:start_backfill)

    described_class.perform_now(2026, dry_run: true)

    expect(DataHub::BlankCoordinatesBackfill::JobOrchestrator).to have_received(:start_backfill).with(2026, dry_run: true)
  end
end
