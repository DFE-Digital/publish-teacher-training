# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverMonitoringJob, type: :job do
  let(:process_summary) { create(:rollover_process_summary) }

  describe "#perform" do
    it "delegates to MonitoringManager" do
      expect(DataHub::Rollover::MonitoringManager).to receive(:check_completion).with(process_summary.id, 1)

      described_class.new.perform(process_summary.id, 1)
    end
  end
end
