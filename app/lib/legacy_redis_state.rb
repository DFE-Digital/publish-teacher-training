# frozen_string_literal: true

# Feature flags and site settings used to live in the worker Redis. The
# database is now the source of truth, and every change is mirrored to Redis
# so a release that still reads Redis can be redeployed. See
# guides/redis-application-state.md.
class LegacyRedisState
  FEATURE_FLAG_PREFIX = "feature_flags_"

  class << self
    def write_feature_flag(name, active:, updated_at:)
      redis.set(feature_flag_key(name), { state: active, updated_at: }.to_json)
    end

    def write_site_setting(name, value)
      redis.set(name, value)
    end

    # Redis to database. Runs once on deploy, and again when rolling forward
    # after a rollback, because the older release only wrote to Redis.
    def backfill_database
      flags = FeatureFlag.features.keys.filter_map do |name|
        raw = redis.get(feature_flag_key(name))
        next if raw.blank?

        data = JSON.parse(raw)
        updated_at = data["updated_at"].present? ? Time.zone.parse(data["updated_at"]) : Time.zone.now

        { name:, active: data["state"] == true, created_at: updated_at, updated_at: }
      end

      settings = SiteSetting::NAMES.filter_map do |name|
        value = redis.get(name)
        next if value.blank?

        { name:, value:, created_at: Time.zone.now, updated_at: Time.zone.now }
      end

      ActiveRecord::Base.transaction do
        FeatureFlagState.upsert_all(flags, unique_by: :name, record_timestamps: false) if flags.any?
        SiteSetting.upsert_all(settings, unique_by: :name, record_timestamps: false) if settings.any?
      end

      { feature_flags: flags.size, site_settings: settings.size }
    end

    # Database to Redis. Run before redeploying a release that reads Redis.
    def sync_to_redis
      FeatureFlagState.find_each do |state|
        write_feature_flag(state.name, active: state.active, updated_at: state.updated_at)
      end

      SiteSetting.find_each do |setting|
        write_site_setting(setting.name, setting.value)
      end

      { feature_flags: FeatureFlagState.count, site_settings: SiteSetting.count }
    end

    # Key counts by prefix and command counters, never values. Form stores
    # can hold personal data.
    def audit
      prefixes = Hash.new(0)
      redis.scan_each(count: 1000) { |key| prefixes[key_prefix(key)] += 1 }

      commands = redis.info("commandstats").slice("get", "set").transform_values { |stats| stats["calls"].to_i }

      { prefixes: prefixes.sort_by { |_prefix, count| -count }.to_h, commands: }
    end

  private

    def feature_flag_key(name)
      "#{FEATURE_FLAG_PREFIX}#{name}"
    end

    def key_prefix(key)
      return key if key.start_with?(FEATURE_FLAG_PREFIX) || key.in?(SiteSetting::NAMES)

      key[/\A[^_:]+(::[^_:]+)?/] || key
    end

    def redis
      RedisClient.current
    end
  end
end
