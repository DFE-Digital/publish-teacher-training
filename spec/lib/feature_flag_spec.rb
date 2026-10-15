# frozen_string_literal: true

require "rails_helper"

describe FeatureFlag do
  before do
    allow(FeatureFlags).to receive(:all).and_return(
      [
        [:test_feature, "It's a test feature", "Jasmine Java"],
        [:other_feature, "Another test feature", "Jasmine Java"],
      ],
    )
  end

  describe ".active?" do
    it "returns false if the feature flag has been deactivated" do
      described_class.deactivate("test_feature")

      expect(described_class.active?("test_feature")).to be(false)
    end

    it "returns true if the feature flag has been activated" do
      described_class.activate("test_feature")

      expect(described_class.active?("test_feature")).to be(true)
    end

    it "returns false if the feature does not exist" do
      expect(described_class.active?("test_feature")).to be(false)
    end

    it "loads every flag in one query per request" do
      FeatureFlagState.create!(name: "test_feature", active: true)
      FeatureFlagState.create!(name: "other_feature", active: false)
      Current.reset

      queries = count_queries do
        5.times do
          described_class.active?(:test_feature)
          described_class.active?(:other_feature)
          described_class.active?(:missing_feature)
        end
      end

      expect(queries).to eq(1)
    end

    it "does not read Redis" do
      expect(RedisClient.current).not_to receive(:get)

      described_class.active?(:test_feature)
    end

    it "updates the request cache when the feature changes" do
      FeatureFlagState.create!(name: "test_feature", active: true)

      expect(described_class.active?("test_feature")).to be(true)

      described_class.deactivate("test_feature")

      expect(described_class.active?("test_feature")).to be(false)
    end
  end

  describe ".activate" do
    it "activates the feature flag" do
      described_class.activate("test_feature")

      expect(FeatureFlagState.find_by(name: "test_feature")).to have_attributes(active: true)
    end

    it "mirrors the state to Redis in the legacy format" do
      freeze_time do
        described_class.activate("test_feature")

        expect(JSON.parse(RedisClient.current.get("feature_flags_test_feature"))).to eq(
          "state" => true,
          "updated_at" => Time.zone.now.as_json,
        )
        state = FeatureFlagState.find_by(name: "test_feature")
        expect(state.legacy_redis_synced_at).to eq(state.updated_at)
      end
    end

    it "keeps the committed database change pending if Redis cannot be written" do
      allow(RedisClient.current).to receive(:set).and_raise(Redis::CannotConnectError)
      allow(Rails.error).to receive(:report)

      expect { described_class.activate("test_feature") }.not_to raise_error

      state = FeatureFlagState.find_by(name: "test_feature")
      expect(state).to have_attributes(active: true, legacy_redis_synced_at: nil)
      expect(Rails.error).to have_received(:report).with(
        instance_of(Redis::CannotConnectError),
        handled: true,
        context: hash_including(source: "legacy_redis_state_mirror"),
      )
    end

    it "raises for an unknown feature" do
      expect { described_class.activate("unknown_feature") }.to raise_error(described_class::UnknownFeatureError)
    end
  end

  describe ".deactivate" do
    it "deactivates the feature flag" do
      described_class.activate("test_feature")
      described_class.deactivate("test_feature")

      expect(described_class.active?("test_feature")).to be(false)
      expect(JSON.parse(RedisClient.current.get("feature_flags_test_feature"))["state"]).to be(false)
    end
  end

  describe ".last_updated" do
    it "returns nil if the flag has never been set" do
      expect(described_class.last_updated("test_feature")).to be_nil
    end

    it "returns when the flag was last changed, even if the state is unchanged" do
      travel_to(2.days.ago) { described_class.activate("test_feature") }

      freeze_time do
        Current.reset
        described_class.activate("test_feature")

        expect(described_class.last_updated("test_feature")).to eq(Time.zone.now)
      end
    end
  end

  def count_queries(&)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name].in?(%w[SCHEMA TRANSACTION]) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
    count
  end
end
