# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverJob, type: :job do
  let(:recruitment_cycle) { RecruitmentCycle.next || create(:recruitment_cycle, :next) }

  describe "#perform" do
    it "delegates to JobOrchestrator" do
      expect(DataHub::Rollover::JobOrchestrator).to receive(:start_rollover).with(recruitment_cycle.id)

      described_class.perform_now(recruitment_cycle.id)
    end
  end

  it "reports a failed orchestration without starting another rollover" do
    allow(DataHub::Rollover::JobOrchestrator).to receive(:start_rollover).and_raise(StandardError, "boom")
    allow(Rails.error).to receive(:report)

    expect { described_class.perform_now(recruitment_cycle.id) }.not_to raise_error

    expect(DataHub::Rollover::JobOrchestrator).to have_received(:start_rollover).once
    expect(Rails.error).to have_received(:report).with(an_instance_of(StandardError), hash_including(source: "application.active_job"))
    expect(described_class).not_to have_been_enqueued
  end
end
