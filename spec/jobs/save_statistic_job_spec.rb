require "rails_helper"
describe SaveStatisticJob, type: :job do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  subject(:job) { described_class.perform_later }

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is put into the save_statistic queue" do
    expect(described_class.new.queue_name).to eq("save_statistic")
  end

  context "executing the job" do
    it "calls the StatisticService to save" do
      expect(StatisticService).to receive(:save)

      perform_enqueued_jobs { job }
    end
  end
end
