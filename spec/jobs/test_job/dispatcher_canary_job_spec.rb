# frozen_string_literal: true

require "rails_helper"

RSpec.describe TestJob::DispatcherCanaryJob do
  it "uses Solid Queue explicitly for this canary job" do
    expect(described_class.queue_adapter).to be_a(ActiveJob::QueueAdapters::SolidQueueAdapter)
  end

  it "can be enqueued onto Solid Queue" do
    expect {
      described_class.set(wait_until: 1.minute.from_now).perform_later
    }.to change(SolidQueue::Job, :count).by(1)

    job = SolidQueue::Job.order(:id).last
    expect(job.class_name).to eq("TestJob::DispatcherCanaryJob")
    expect(job.queue_name).to eq("default")
  end

  it "performs without side effects beyond logging" do
    expect { described_class.perform_now }.not_to raise_error
  end
end
