# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverProviderJob, type: :job do
  let(:process_summary) { create(:rollover_process_summary) }

  describe "#perform" do
    it "delegates to ProviderProcessor" do
      expect(DataHub::Rollover::ProviderProcessor).to receive(:process).with("ABC", 123, process_summary.id)

      described_class.perform_now("ABC", 123, process_summary.id)
    end
  end

  it "discards StandardError without re-raising or re-enqueueing" do
    expect(DataHub::Rollover::ProviderProcessor).to receive(:process).once.and_raise(StandardError, "boom")
    allow(Rails.error).to receive(:report)

    expect {
      described_class.perform_now("ABC", 123, process_summary.id)
    }.not_to raise_error

    expect(Rails.error).to have_received(:report).with(
      an_instance_of(StandardError),
      hash_including(source: "application.active_job"),
    )
  end
end
