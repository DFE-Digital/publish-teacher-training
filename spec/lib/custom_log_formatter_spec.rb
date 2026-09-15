# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomLogFormatter do
  subject(:log_hash) { JSON.parse(described_class.new.call(log, logger), symbolize_names: true) }

  let(:log) { SemanticLogger::Log.new("Test", :info) }
  let(:logger) do
    SemanticLogger::Appender::File.new(
      "tmp/custom_log_formatter_spec.log",
      retry_count: 1,
      append: true,
      reopen_period: nil,
      reopen_count: 0,
      reopen_size: 0,
      encoding: Encoding::BINARY,
      exclusive_lock: false,
    )
  end

  it "redacts Solid Queue job arguments" do
    log.message = "Performed TestJob::DispatcherCanaryJob"
    log.payload = {
      job_class: "TestJob::DispatcherCanaryJob",
      adapter: "SolidQueue",
      arguments: [{ email: "secret@example.com", token: "abc" }],
    }

    expect(log_hash[:payload][:arguments]).to eq("[REDACTED]")
    expect(log_hash[:payload][:job_class]).to eq("TestJob::DispatcherCanaryJob")
  end

  it "does not redact arguments for non-Solid Queue adapters" do
    log.message = "Performed SomeJob"
    log.payload = {
      job_class: "SomeJob",
      adapter: "Sidekiq",
      arguments: [{ email: "secret@example.com" }],
    }

    expect(log_hash[:payload][:arguments]).to eq([{ email: "secret@example.com" }])
  end
end
