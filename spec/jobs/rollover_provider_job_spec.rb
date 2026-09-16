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

  it "does not automatically retry StandardError" do
    retry_handlers = described_class.rescue_handlers.select { |handler| handler.first == "StandardError" }

    expect(retry_handlers).not_to be_empty
  end
end
