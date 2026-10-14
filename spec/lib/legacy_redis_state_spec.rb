# frozen_string_literal: true

require "rails_helper"

describe LegacyRedisState do
  let(:redis) { RedisClient.current }

  before do
    allow(FeatureFlags).to receive(:all).and_return(
      [
        [:test_feature, "It's a test feature", "Jasmine Java"],
        [:other_feature, "Another test feature", "Jasmine Java"],
      ],
    )
  end

  describe ".backfill_database" do
    it "copies flag states, last-updated times and settings from Redis" do
      updated_at = Time.zone.local(2026, 9, 1, 10, 30)
      redis.set("feature_flags_test_feature", { state: true, updated_at: }.to_json)
      redis.set("feature_flags_other_feature", { state: false, updated_at: }.to_json)
      redis.set("cycle_schedule", "apply_open")
      redis.set("deadline_banner", "true")

      expect(described_class.backfill_database).to eq(feature_flags: 2, site_settings: 2)

      expect(FeatureFlagState.pluck(:name, :active, :updated_at)).to contain_exactly(
        ["test_feature", true, updated_at],
        ["other_feature", false, updated_at],
      )
      expect(SiteSetting.pluck(:name, :value)).to contain_exactly(
        %w[cycle_schedule apply_open],
        %w[deadline_banner true],
      )
    end

    it "ignores flags that are no longer defined" do
      redis.set("feature_flags_retired_feature", { state: true, updated_at: Time.zone.now }.to_json)

      described_class.backfill_database

      expect(FeatureFlagState.count).to eq(0)
    end

    it "overwrites the database so it can be rerun after a rollback" do
      FeatureFlagState.create!(name: "test_feature", active: true)
      SiteSetting.create!(name: "cycle_schedule", value: "find_closed")
      redis.set("feature_flags_test_feature", { state: false, updated_at: Time.zone.now }.to_json)
      redis.set("cycle_schedule", "real")

      described_class.backfill_database

      expect(FeatureFlagState.find_by(name: "test_feature").active).to be(false)
      expect(SiteSetting.find_by(name: "cycle_schedule").value).to eq("real")
    end
  end

  describe ".sync_to_redis" do
    it "writes the database values to Redis in the format older releases read" do
      updated_at = Time.zone.local(2026, 9, 1, 10, 30)
      FeatureFlagState.create!(name: "test_feature", active: true, updated_at:)
      SiteSetting.create!(name: "cycle_schedule", value: "apply_open")

      expect(described_class.sync_to_redis).to eq(feature_flags: 1, site_settings: 1)

      expect(JSON.parse(redis.get("feature_flags_test_feature"))).to eq(
        "state" => true,
        "updated_at" => updated_at.as_json,
      )
      expect(redis.get("cycle_schedule")).to eq("apply_open")
    end

    it "round-trips through a backfill" do
      freeze_time
      FeatureFlag.activate(:test_feature)
      SiteSetting.set(name: "cycle_schedule", value: "apply_open")
      before_values = FeatureFlagState.pluck(:name, :active, :updated_at)

      described_class.sync_to_redis
      FeatureFlagState.delete_all
      SiteSetting.delete_all
      described_class.backfill_database

      expect(FeatureFlagState.pluck(:name, :active, :updated_at)).to eq(before_values)
      expect(SiteSetting.pluck(:name, :value)).to eq([%w[cycle_schedule apply_open]])
    end
  end

  describe ".audit" do
    it "counts keys by prefix without returning values" do
      redis.set("feature_flags_test_feature", { state: true }.to_json)
      redis.set("Stores::UserStore_1_user", { email: "someone@example.com" }.to_json)
      redis.set("Stores::UserStore_2_user", { email: "other@example.com" }.to_json)
      redis.set("stat:processed:2026-10-14", "1")
      allow(redis).to receive(:info).with("commandstats").and_return("get" => { "calls" => "5" }, "set" => { "calls" => "3" })

      result = described_class.audit

      expect(result[:prefixes]).to eq(
        "Stores::UserStore" => 2,
        "feature_flags_test_feature" => 1,
        "stat" => 1,
      )
      expect(result[:commands]).to eq("get" => 5, "set" => 3)
      expect(result.to_s).not_to include("example.com")
    end
  end
end
