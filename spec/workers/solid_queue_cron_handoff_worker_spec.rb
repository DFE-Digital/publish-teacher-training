# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidQueueCronHandoffWorker do
  include ActiveJob::TestHelper

  describe ".wrap" do
    subject(:wrapped_jobs) { described_class.wrap(cron_jobs) }

    let(:cron_jobs) do
      {
        import_gias_schools: {
          cron: "30 2 * * *",
          class: "GiasImportJob",
          queue: "low_priority",
        },
        send_entity_table_checks_to_bigquery: {
          cron: "30 0 * * *",
          class: "DfE::Analytics::EntityTableCheckJob",
          queue: "low_priority",
        },
      }
    end

    it "routes Solid Queue cron entries through the native Sidekiq worker" do
      original = cron_jobs.fetch(:import_gias_schools)
      wrapped = wrapped_jobs.fetch(:import_gias_schools)

      expect(wrapped).to include(
        cron: original.fetch(:cron),
        class: described_class.name,
        queue: original.fetch(:queue),
        args: ["GiasImportJob", [], original.fetch(:queue)],
      )
    end

    it "leaves jobs using another adapter unchanged" do
      original = cron_jobs.fetch(:send_entity_table_checks_to_bigquery)

      expect(wrapped_jobs.fetch(:send_entity_table_checks_to_bigquery)).to eq(original)
    end

    it "preserves target arguments and queue" do
      jobs = {
        example: {
          cron: "0 0 * * *",
          class: "BulkUpdateCourseSchoolsJob",
          args: [[1, 2], %w[added], %w[removed]],
          queue: "low_priority",
        },
      }

      wrapped = described_class.wrap(jobs).fetch(:example)

      expect(wrapped.fetch(:args)).to eq(
        ["BulkUpdateCourseSchoolsJob", [[1, 2], %w[added], %w[removed]], "low_priority"],
      )
      expect(wrapped.fetch(:queue)).to eq("low_priority")
    end
  end

  describe "#perform" do
    it "enqueues the target job on its configured queue" do
      expect {
        described_class.new.perform("GiasImportJob", [], "low_priority")
      }.to have_enqueued_job(GiasImportJob).on_queue("low_priority")
    end

    it "raises when Solid Queue cannot accept the handoff so Sidekiq retries it" do
      configured_job = instance_double(ActiveJob::ConfiguredJob)
      allow(GiasImportJob).to receive(:set).with(queue: "low_priority").and_return(configured_job)
      allow(configured_job).to receive(:perform_later)
        .and_raise(SolidQueue::Job::EnqueueError, "database unavailable")

      expect {
        described_class.new.perform("GiasImportJob", [], "low_priority")
      }.to raise_error(SolidQueue::Job::EnqueueError, "database unavailable")
    end
  end
end
