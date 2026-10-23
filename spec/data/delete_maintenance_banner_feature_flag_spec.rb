# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261020150000_delete_maintenance_banner_feature_flag")

describe DeleteMaintenanceBannerFeatureFlag do
  it "deletes the maintenance banner flag from the database and Redis and leaves other flags alone" do
    FeatureFlagState.create!(name: "maintenance_banner", active: true)
    FeatureFlagState.create!(name: "maintenance_mode", active: false)
    RedisClient.current.set("feature_flags_maintenance_banner", { state: true }.to_json)
    RedisClient.current.set("feature_flags_maintenance_mode", { state: false }.to_json)

    described_class.new.up

    expect(FeatureFlagState.pluck(:name)).to eq(%w[maintenance_mode])
    expect(RedisClient.current.get("feature_flags_maintenance_banner")).to be_nil
    expect(RedisClient.current.get("feature_flags_maintenance_mode")).to be_present
  end
end
