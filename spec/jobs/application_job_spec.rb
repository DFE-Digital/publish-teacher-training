# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  describe ".without_auto_retry" do
    around do |example|
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      clear_enqueued_jobs
      example.run
    ensure
      clear_enqueued_jobs
      ActiveJob::Base.queue_adapter = original_adapter
    end

    let(:job_class) do
      Class.new(ApplicationJob) do
        without_auto_retry

        cattr_accessor :calls

        def perform(action = :standard)
          self.class.calls += 1

          case action
          when :standard then raise StandardError, "boom"
          when :deadlocked then raise ActiveRecord::Deadlocked, "deadlock" if self.class.calls == 1
          end
        end
      end
    end

    before do
      stub_const("WithoutAutoRetryExampleJob", job_class)
      WithoutAutoRetryExampleJob.calls = 0
    end

    it "discards StandardError and reports it through the error reporter" do
      expect(Rails.error).to receive(:report).with(
        an_instance_of(StandardError),
        hash_including(source: "application.active_job"),
      )

      expect {
        WithoutAutoRetryExampleJob.perform_now(:standard)
      }.not_to raise_error

      expect(WithoutAutoRetryExampleJob).not_to have_been_enqueued
    end

    it "retries ActiveRecord::Deadlocked despite the StandardError discard" do
      expect {
        WithoutAutoRetryExampleJob.perform_now(:deadlocked)
      }.to have_enqueued_job(WithoutAutoRetryExampleJob)

      expect(WithoutAutoRetryExampleJob.calls).to eq(1)
    end
  end

  describe ".fail_without_retry_on" do
    let(:job_class) do
      Class.new(ApplicationJob) do
        retry_on ActiveRecord::Deadlocked
        fail_without_retry_on ActiveRecord::Deadlocked

        def perform
          raise ActiveRecord::Deadlocked, "ambiguous side effect"
        end
      end
    end

    before { stub_const("FailWithoutRetryExampleJob", job_class) }

    it "overrides an earlier retry handler and raises the failure" do
      allow(Sidekiq).to receive(:server?).and_return(false)

      expect {
        FailWithoutRetryExampleJob.perform_now
      }.to raise_error(ActiveRecord::Deadlocked, "ambiguous side effect")

      expect(FailWithoutRetryExampleJob).not_to have_been_enqueued
    end

    it "reports and consumes a legacy Sidekiq payload so its wrapper cannot retry" do
      allow(Sidekiq).to receive(:server?).and_return(true)
      allow(Rails.error).to receive(:report)
      wrapper = ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.new
      wrapper.jid = "legacy-sidekiq-jid"

      expect {
        wrapper.perform(FailWithoutRetryExampleJob.new.serialize)
      }.not_to raise_error

      expect(Rails.error).to have_received(:report).with(
        an_instance_of(ActiveRecord::Deadlocked),
        handled: true,
        source: "application.active_job",
      )
      expect(FailWithoutRetryExampleJob).not_to have_been_enqueued
    end
  end

  describe ".retry_on_failure" do
    around do |example|
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      clear_enqueued_jobs
      example.run
    ensure
      clear_enqueued_jobs
      ActiveJob::Base.queue_adapter = original_adapter
    end

    let(:job_class) do
      Class.new(ApplicationJob) do
        retry_on_failure attempts: 2

        def perform(action = :standard)
          case action
          when :standard then raise StandardError, "boom"
          when :deserialization
            begin
              raise ActiveRecord::RecordNotFound
            rescue ActiveRecord::RecordNotFound
              raise ActiveJob::DeserializationError
            end
          end
        end
      end
    end

    before { stub_const("RetryOnFailureExampleJob", job_class) }

    it "re-enqueues a StandardError until attempts run out, then raises without enqueuing again" do
      expect {
        RetryOnFailureExampleJob.perform_now(:standard)
      }.to have_enqueued_job(RetryOnFailureExampleJob).exactly(:once)

      expect { perform_enqueued_jobs }.to raise_error(/boom/)
      expect(RetryOnFailureExampleJob).not_to have_been_enqueued
    end

    it "still discards jobs whose records have gone" do
      expect {
        RetryOnFailureExampleJob.perform_now(:deserialization)
      }.not_to raise_error

      expect(RetryOnFailureExampleJob).not_to have_been_enqueued
    end
  end
end
