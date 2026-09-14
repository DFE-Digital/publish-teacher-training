# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Solid Queue" do
  it "uses plural table names despite app-wide singularisation" do
    expect(SolidQueue::Job.table_name).to eq("solid_queue_jobs")
    expect(SolidQueue::FailedExecution.table_name).to eq("solid_queue_failed_executions")
    expect(SolidQueue::Batch.table_name).to eq("solid_queue_batches")
  end

  it "uses the primary database (no separate queue DB)" do
    expect(SolidQueue::Record.connection_db_config.name).to eq("primary")
  end

  it "retains finished jobs for one hour" do
    expect(SolidQueue.clear_finished_jobs_after).to eq(1.hour)
  end
end
