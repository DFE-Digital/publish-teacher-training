# frozen_string_literal: true

require "rails_helper"
describe SaveStatisticJob do
  subject(:job) { described_class.perform_later }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it_behaves_like "a Solid Queue job", queue: "low_priority"

  context "executing the job" do
    it "calls the StatisticService to save" do
      expect(StatisticService).to receive(:save)

      perform_enqueued_jobs { job }
    end
  end
end
