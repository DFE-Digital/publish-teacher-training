# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverProviderJob, type: :job do
  let(:process_summary) { create(:rollover_process_summary) }

  describe "#perform" do
    it "delegates to ProviderProcessor" do
      expect(DataHub::Rollover::ProviderProcessor).to receive(:process).with("ABC", 123, process_summary.id)

      described_class.new.perform("ABC", 123, process_summary.id)
    end
  end
end
