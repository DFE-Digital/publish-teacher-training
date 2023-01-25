require "http"

module Find
  class SlackNotificationJob < ApplicationJob
    SLACK_CHANNEL = "#twd_findpub_tech".freeze

    def perform(text, url = nil)
      @webhook_url = Settings.STATE_CHANGE_SLACK_URL
      if @webhook_url.present?
        message = url.present? ? hyperlink(text, url) : text
        post_to_slack message
      end
    end

  private

    def hyperlink(text, url)
      "<#{url}|#{text}>"
    end

    def post_to_slack(text)
      payload = {
        username: "Find postgraduate teacher training",
        channel: SLACK_CHANNEL,
        text:,
        mrkdwn: true,
        icon_emoji: ":livecanary:",
      }

      response = HTTP.post(@webhook_url, body: payload.to_json)

      raise SlackMessageError, "Slack error: #{response.body}" unless response.status.success?
    end

    class SlackMessageError < StandardError; end
  end
end
