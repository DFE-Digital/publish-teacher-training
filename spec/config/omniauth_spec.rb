# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OmniAuth configuration" do
  it "allowlists Find and Publish hosts against forged request hosts" do
    expect(OmniAuth.config.allowed_hosts).to match_array(
      Settings.find_hosts + Settings.publish_hosts,
    )
  end
end
