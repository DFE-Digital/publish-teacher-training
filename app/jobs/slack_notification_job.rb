# frozen_string_literal: true

require "http"

class SlackNotificationJob < ApplicationJob
  class SlackMessageError < StandardError; end
  class SlackServerError < SlackMessageError; end

  self.queue_adapter = :solid_queue

  # A 4xx means the webhook or payload is wrong, and will be wrong next time too.
  retry_on SlackServerError, HTTP::ConnectionError, HTTP::TimeoutError, attempts: 3, wait: :polynomially_longer

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

    error = response.status.server_error? ? SlackServerError : SlackMessageError
    raise error, "Slack error: #{response.body}"
  end
end
