# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlankCoordinatesBackfill::BackfillJob do
  it "runs the orchestrator on Solid Queue's low priority queue" do
    expect(described_class.queue_adapter_name).to eq("solid_queue")
    expect(described_class.new.queue_name).to eq("low_priority")
  end

  it "delegates to the backfill orchestrator" do
    allow(DataHub::BlankCoordinatesBackfill::JobOrchestrator).to receive(:start_backfill)

    described_class.new.perform("2026", dry_run: true)

    expect(DataHub::BlankCoordinatesBackfill::JobOrchestrator)
      .to have_received(:start_backfill).with("2026", dry_run: true)
  end

  it "does not retry a deadlock after orchestration may have partially scheduled batches" do
    allow(DataHub::BlankCoordinatesBackfill::JobOrchestrator).to receive(:start_backfill)
      .and_raise(ActiveRecord::Deadlocked, "deadlock")

    expect {
      described_class.perform_now("2026")
    }.to raise_error(ActiveRecord::Deadlocked, "deadlock")

    expect(described_class).not_to have_been_enqueued
  end
end
