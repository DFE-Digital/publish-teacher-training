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
      records = [
        FeatureFlagState.create!(name: "test_feature", active: true),
        FeatureFlagState.create!(name: "other_feature", active: true),
        SiteSetting.create!(name: "cycle_schedule", value: "find_closed"),
        SiteSetting.create!(name: "deadline_banner", value: "true"),
      ]
      records.each { |record| record.update_column(:legacy_redis_synced_at, record.updated_at) }
      redis.set("feature_flags_test_feature", { state: false, updated_at: Time.zone.now }.to_json)
      redis.set("cycle_schedule", "real")

      described_class.backfill_database

      expect(FeatureFlagState.find_by(name: "test_feature").active).to be(false)
      expect(FeatureFlagState.exists?(name: "other_feature")).to be(false)
      expect(SiteSetting.find_by(name: "cycle_schedule").value).to eq("real")
      expect(SiteSetting.exists?(name: "deadline_banner")).to be(false)
    end

    it "keeps the timestamp of an unchanged setting during web boot" do
      updated_at = 2.days.ago
      setting = SiteSetting.create!(name: "cycle_schedule", value: "apply_open", updated_at:)
      setting.update_column(:legacy_redis_synced_at, setting.updated_at)
      redis.set("cycle_schedule", "apply_open")

      described_class.backfill_database

      expect(setting.reload.updated_at).to be_within(0.001).of(updated_at)
    end

    it "pushes a pending database change before importing Redis" do
      state = FeatureFlagState.create!(name: "test_feature", active: true)
      setting = SiteSetting.create!(name: "cycle_schedule", value: "apply_open")
      redis.set("feature_flags_test_feature", { state: false, updated_at: 1.day.ago }.to_json)
      redis.set("cycle_schedule", "find_closed")

      described_class.backfill_database

      expect(state.reload).to have_attributes(active: true, legacy_redis_synced_at: state.updated_at)
      expect(setting.reload).to have_attributes(value: "apply_open", legacy_redis_synced_at: setting.updated_at)
      expect(JSON.parse(redis.get("feature_flags_test_feature"))["state"]).to be(true)
      expect(redis.get("cycle_schedule")).to eq("apply_open")
    end

    it "keeps database rows when Redis is empty instead of wiping them" do
      records = [
        FeatureFlagState.create!(name: "test_feature", active: true),
        SiteSetting.create!(name: "cycle_schedule", value: "apply_open"),
      ]
      records.each { |record| record.update_column(:legacy_redis_synced_at, record.updated_at) }
      allow(Rails.error).to receive(:report)

      expect(described_class.backfill_database).to eq(feature_flags: 0, site_settings: 0)

      expect(FeatureFlagState.pluck(:name, :active)).to eq([["test_feature", true]])
      expect(SiteSetting.pluck(:name, :value)).to eq([%w[cycle_schedule apply_open]])
      expect(Rails.error).to have_received(:report).twice
    end

    it "continues with database state when Redis is unavailable" do
      state = FeatureFlagState.create!(name: "test_feature", active: true)
      state.update_column(:legacy_redis_synced_at, state.updated_at)
      allow(RedisClient).to receive(:current).and_raise(Redis::CannotConnectError, "down")
      allow(Rails.error).to receive(:report)

      expect(described_class.backfill_database).to eq(
        feature_flags: 0,
        site_settings: 0,
        skipped: :redis_unavailable,
      )

      expect(FeatureFlagState.pluck(:name, :active)).to eq([["test_feature", true]])
      expect(Rails.error).to have_received(:report).with(
        an_instance_of(Redis::CannotConnectError),
        hash_including(handled: true, context: hash_including(source: "legacy_redis_state_reconcile")),
      )
    end
  end

  describe ".sync_to_redis" do
    it "writes the database values to Redis in the format older releases read" do
      updated_at = Time.zone.local(2026, 9, 1, 10, 30)
      FeatureFlagState.create!(name: "test_feature", active: true, updated_at:)
      SiteSetting.create!(name: "cycle_schedule", value: "apply_open")
      redis.set("feature_flags_other_feature", { state: true, updated_at: }.to_json)
      redis.set("deadline_banner", "true")

      expect(described_class.sync_to_redis).to eq(feature_flags: 1, site_settings: 1)

      expect(JSON.parse(redis.get("feature_flags_test_feature"))).to eq(
        "state" => true,
        "updated_at" => updated_at.as_json,
      )
      expect(redis.get("cycle_schedule")).to eq("apply_open")
      expect(redis.get("feature_flags_other_feature")).to be_nil
      expect(redis.get("deadline_banner")).to be_nil
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

  describe ".with_state_lock" do
    it "excludes another database session" do
      lock_key = described_class::ADVISORY_LOCK_KEY.join(", ")
      stub_const("OtherDatabaseConnection", Class.new(ApplicationRecord) { self.abstract_class = true })
      other_database = OtherDatabaseConnection
      other_database.establish_connection(ActiveRecord::Base.connection_db_config.configuration_hash)

      described_class.with_state_lock do
        acquired = other_database.connection.select_value("SELECT pg_try_advisory_lock(#{lock_key})")
        expect(acquired).to be(false)
      end
    ensure
      other_database&.connection_pool&.disconnect!
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
