# frozen_string_literal: true

require "http"

class SlackNotificationJob < ApplicationJob
  class SlackMessageError < StandardError; end
  class SlackServerError < SlackMessageError; end
  class SlackRateLimitError < SlackMessageError; end

  self.queue_adapter = :solid_queue

  # Most 4xx responses mean the webhook or payload will still be wrong next time.
  # Slack's 429 response is transient and gets a slower, separate retry policy.
  retry_on SlackServerError, HTTP::ConnectionError, HTTP::TimeoutError, attempts: 3, wait: :polynomially_longer
  retry_on SlackRateLimitError, attempts: 5, wait: 1.minute

  SLACK_CHANNEL = "#twd_findpub_tech"

  def perform(text, url = nil)
    @webhook_url = Settings.STATE_CHANGE_SLACK_URL
    return if @webhook_url.blank?

    message = url.present? ? hyperlink(text, url) : text
    post_to_slack message
  end

private

  def hyperlink(text, url)
    "<#{url}|#{text}>"
  end

  def post_to_slack(text)
    payload = {
      username: "Find teacher training courses",
      channel: SLACK_CHANNEL,
      text:,
      mrkdwn: true,
      icon_emoji: ":livecanary:",
    }

    response = HTTP.post(@webhook_url, body: payload.to_json)

    return if response.status.success?

    error = if response.status == 429
              SlackRateLimitError
            elsif response.status.server_error?
              SlackServerError
            else
              SlackMessageError
            end
    raise error, "Slack error: #{response.body}"
  end
end
