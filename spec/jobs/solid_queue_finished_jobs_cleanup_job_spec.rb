# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidQueueFinishedJobsCleanupJob do
  it_behaves_like "a job routed to Solid Queue", queue: "low_priority"

  def solid_queue_job(finished_at:)
    SolidQueue::Job.create!(queue_name: "default", class_name: "TestJob::DispatcherCanaryJob").tap do |job|
      job.update_columns(finished_at:)
    end
  end

  it "clears finished jobs past the retention period and keeps the rest", :solid_queue do
    expired = solid_queue_job(finished_at: 2.hours.ago)
    recent = solid_queue_job(finished_at: 10.minutes.ago)
    unfinished = solid_queue_job(finished_at: nil)

    described_class.perform_now

    expect(SolidQueue::Job.where(id: [expired.id, recent.id, unfinished.id]).pluck(:id))
      .to contain_exactly(recent.id, unfinished.id)
  end
end
