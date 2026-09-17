# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings" do
  it "leaves the Slack webhook blank, so SlackNotificationJob's guard holds until one is supplied" do
    webhook_urls = %w[config/settings.yml config/settings/production.yml].index_with do |path|
      YAML.safe_load_file(Rails.root.join(path))["STATE_CHANGE_SLACK_URL"]
    end

    expect(webhook_urls).to eq(
      "config/settings.yml" => nil,
      "config/settings/production.yml" => nil,
    )
  end
end
