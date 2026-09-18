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

  describe "Solid Queue argument redaction" do
    # Keys covered by filter_parameters and Mission Control's extra argument names.
    {
      email: "secret@example.com",
      email_address: "secret@example.com",
      token: "abc",
      password: "s3cret",
      secret: "shh",
      first_name: "Sam",
      last_name: "Johnson",
      code: "magic-link",
      data: { nested: true },
      body: "mail body",
      hidden_data: "x",
      headers: { "Authorization" => "Bearer x" },
    }.each do |key, value|
      it "redacts #{key} and leaves non-sensitive args" do
        log.message = "Performed TestJob::DispatcherCanaryJob"
        log.payload = {
          job_class: "TestJob::DispatcherCanaryJob",
          adapter: "SolidQueue",
          arguments: [{ key => value, course_id: 123 }],
        }

        expect(log_hash[:payload][:arguments]).to eq(
          [{ key => "[REDACTED]", course_id: 123 }],
        )
        expect(log_hash[:payload][:job_class]).to eq("TestJob::DispatcherCanaryJob")
      end
    end

    it "leaves wholly non-sensitive arguments unredacted" do
      log.message = "Performed UpdateCourseSchoolsJob"
      log.payload = {
        job_class: "UpdateCourseSchoolsJob",
        adapter: "SolidQueue",
        arguments: [42, %w[uuid-1 uuid-2]],
      }

      expect(log_hash[:payload][:arguments]).to eq([42, %w[uuid-1 uuid-2]])
    end
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
