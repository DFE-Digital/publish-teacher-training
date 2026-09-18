# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  include ActiveJob::TestHelper

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
end
