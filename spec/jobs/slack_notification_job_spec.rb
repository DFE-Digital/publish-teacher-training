# frozen_string_literal: true

require "rails_helper"

describe SlackNotificationJob do
  describe "#perform" do
    it "sends a Slack notification to this webhook if the URL is set" do
      slack_request = stub_request(:post, "https://example.com/webhook")
                      .to_return(status: 200, headers: {})
      invoke_worker

      expect(slack_request).to have_been_made
    end

    it "does not send a Slack notification if STATE_CHANGE_SLACK_URL is empty" do
      allow(Settings).to receive(:STATE_CHANGE_SLACK_URL).and_return(nil)
      slack_request = stub_request(:post, "https://example.com/webhook")
                      .to_return(status: 200, headers: {})
      invoke_worker

      expect(slack_request).not_to have_been_made
    end

    it "raises an error if Slack responds with one" do
      stub_request(:post, "https://example.com/webhook")
        .to_return(status: 400, headers: {})

      expect { invoke_worker }.to raise_error(SlackNotificationJob::SlackMessageError)
    end

    it "includes a link if given" do
      slack_request = stub_request(:post, "https://example.com/webhook")
                      .to_return(status: 200, headers: {})

      invoke_worker

      # Slack will begin the message with a < character (this codepoint) when presenting content as a link
      expect(slack_request.with(body: /\\u003/)).to have_been_made
    end

    it "does not include a link if none given" do
      slack_request = stub_request(:post, "https://example.com/webhook")
                      .to_return(status: 200, headers: {})

      described_class.new.perform("example text")

      expect(slack_request.with(body: /example text/)).to have_been_made
    end
  end

  describe "retries" do
    include ActiveJob::TestHelper

    it "tries again when Slack has a server error" do
      stub_request(:post, "https://example.com/webhook").to_return(status: 503)

      expect { described_class.perform_now("example text") }.to have_enqueued_job(described_class)
    end

    it "tries a rate-limited request again after one minute" do
      stub_request(:post, "https://example.com/webhook").to_return(status: 429)

      expect { described_class.perform_now("example text") }
        .to have_enqueued_job(described_class).at(a_value_between(1.minute.from_now, 70.seconds.from_now))
    end

    it "does not retry when Slack rejects the message" do
      stub_request(:post, "https://example.com/webhook").to_return(status: 400)

      expect { described_class.perform_now("example text") }.to raise_error(SlackNotificationJob::SlackMessageError)
      expect(described_class).not_to have_been_enqueued
    end
  end

  def invoke_worker
    described_class.new.perform("example text", "https://example.com/support")
  end
end
