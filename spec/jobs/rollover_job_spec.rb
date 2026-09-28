# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverJob, type: :job do
  let(:recruitment_cycle) { RecruitmentCycle.next || create(:recruitment_cycle, :next) }

  it_behaves_like "a job routed to Solid Queue", queue: "default" do
    let(:solid_queue_job_args) { [1] }
  end

  describe "#perform" do
    it "delegates to JobOrchestrator" do
      expect(DataHub::Rollover::JobOrchestrator).to receive(:start_rollover).with(recruitment_cycle.id)

      described_class.perform_now(recruitment_cycle.id)
    end
  end
end
