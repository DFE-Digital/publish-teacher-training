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

    it "falls back to the target job's own queue when the entry has none" do
      jobs = { example: { cron: "0 0 * * *", class: "GiasImportJob" } }

      wrapped = described_class.wrap(jobs).fetch(:example)

      expect(wrapped).to include(queue: "low_priority", args: ["GiasImportJob", [], "low_priority"])
    end

    it "leaves an entry naming an unknown class unchanged instead of raising" do
      jobs = { example: { cron: "0 0 * * *", class: "NoSuchJob", queue: "default" } }

      expect(described_class.wrap(jobs)).to eq(jobs)
    end

    %w[production qa staging].each do |env|
      it "wraps every Solid Queue entry in the #{env} Sidekiq Cron settings" do
        bg_jobs = YAML.safe_load(
          ERB.new(Rails.root.join("config/settings/#{env}.yml").read).result,
          aliases: true,
        ).fetch("bg_jobs").deep_symbolize_keys

        described_class.wrap(bg_jobs).each do |key, wrapped|
          target = bg_jobs.dig(key, :class).constantize

          if target.respond_to?(:queue_adapter_name) && target.queue_adapter_name == "solid_queue"
            expect(wrapped).to include(class: described_class.name, queue: target.new.queue_name)
          else
            expect(wrapped).to eq(bg_jobs.fetch(key))
          end
        end
      end
    end
  end

  it "gives up on a failed handoff after a few retries" do
    expect(described_class.get_sidekiq_options["retry"]).to eq(5)
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
