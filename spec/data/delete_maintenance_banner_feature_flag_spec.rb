# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261020150000_delete_maintenance_banner_feature_flag")

describe DeleteMaintenanceBannerFeatureFlag do
  it "deletes the maintenance banner flag and leaves other flags alone" do
    FeatureFlagState.create!(name: "maintenance_banner", active: true)
    FeatureFlagState.create!(name: "maintenance_mode", active: false)

    described_class.new.up

    expect(FeatureFlagState.pluck(:name)).to eq(%w[maintenance_mode])
  end
end
