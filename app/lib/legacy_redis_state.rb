# frozen_string_literal: true

# Feature flags and site settings used to live in the worker Redis. The
# database is the runtime source of truth, and every change is mirrored to
# Redis so a release that still reads Redis can be redeployed. A shared lock
# serialises those writes with boot reconciliation and database restores. See
# guides/redis-application-state.md.
class LegacyRedisState
  FEATURE_FLAG_PREFIX = "feature_flags_"
  ADVISORY_LOCK_KEY = [20_261_015, 6_581].freeze

  class << self
    def with_state_lock
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        connection.execute(advisory_lock_sql("pg_advisory_lock"))

        begin
          yield
        ensure
          connection.execute(advisory_lock_sql("pg_advisory_unlock"))
        end
      end
    end

    # These mirrors run after the database transaction commits. If Redis is
    # unavailable, the nil sync marker makes web boot retry the write before
    # it imports any legacy Redis values.
    def mirror_feature_flag(state)
      write_feature_flag(state)
      mark_synced(state)
    rescue Redis::BaseError, ActiveRecord::ActiveRecordError => e
      report_mirror_error(e, state)
    end

    def mirror_site_setting(setting)
      write_site_setting(setting)
      mark_synced(setting)
    rescue Redis::BaseError, ActiveRecord::ActiveRecordError => e
      report_mirror_error(e, setting)
    end

    # Redis to database. Runs before every web boot while rollback compatibility
    # is needed. Absence in Redis means the application's default state, so
    # remove database rows that have no corresponding legacy key.
    def backfill_database
      with_state_lock do
        sync_pending_to_redis

        flags = FeatureFlag.features.keys.filter_map do |name|
          raw = redis.get(feature_flag_key(name))
          next if raw.blank?

          data = JSON.parse(raw)
          updated_at = data["updated_at"].present? ? Time.zone.parse(data["updated_at"]) : Time.zone.now

          {
            name:,
            active: data["state"] == true,
            created_at: updated_at,
            updated_at:,
            legacy_redis_synced_at: updated_at,
          }
        end

        existing_settings = SiteSetting.where(name: SiteSetting::NAMES).index_by(&:name)
        settings = SiteSetting::NAMES.filter_map do |name|
          value = redis.get(name)
          next if value.blank?

          existing = existing_settings[name]
          changed_at = existing&.value == value ? existing.updated_at : Time.zone.now

          {
            name:,
            value:,
            created_at: existing&.created_at || changed_at,
            updated_at: changed_at,
            legacy_redis_synced_at: changed_at,
          }
        end

        ActiveRecord::Base.transaction do
          FeatureFlagState.where.not(name: flags.pluck(:name)).delete_all
          SiteSetting.where.not(name: settings.pluck(:name)).delete_all
          if flags.any?
            FeatureFlagState.upsert_all(
              flags,
              unique_by: :name,
              update_only: %i[active updated_at legacy_redis_synced_at],
              record_timestamps: false,
            )
          end
          if settings.any?
            SiteSetting.upsert_all(
              settings,
              unique_by: :name,
              update_only: %i[value updated_at legacy_redis_synced_at],
              record_timestamps: false,
            )
          end
        end

        { feature_flags: flags.size, site_settings: settings.size }
      end
    end

    # Database to Redis. Run before redeploying a release that reads Redis.
    def sync_to_redis
      with_state_lock do
        feature_names = FeatureFlag.features.keys.map(&:to_s)
        states = FeatureFlagState.where(name: feature_names).index_by(&:name)
        settings = SiteSetting.where(name: SiteSetting::NAMES).index_by(&:name)

        feature_names.each do |name|
          state = states[name]
          state ? write_feature_flag(state) : redis.del(feature_flag_key(name))
          mark_synced(state) if state
        end

        SiteSetting::NAMES.each do |name|
          setting = settings[name]
          setting ? write_site_setting(setting) : redis.del(name)
          mark_synced(setting) if setting
        end

        { feature_flags: states.size, site_settings: settings.size }
      end
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

    def sync_pending_to_redis
      FeatureFlagState.where(legacy_redis_synced_at: nil).find_each do |state|
        write_feature_flag(state)
        mark_synced(state)
      end

      SiteSetting.where(legacy_redis_synced_at: nil).find_each do |setting|
        write_site_setting(setting)
        mark_synced(setting)
      end
    end

    def write_feature_flag(state)
      redis.set(
        feature_flag_key(state.name),
        { state: state.active, updated_at: state.updated_at }.to_json,
      )
    end

    def write_site_setting(setting)
      redis.set(setting.name, setting.value)
    end

    def mark_synced(record)
      record.update_column(:legacy_redis_synced_at, record.updated_at)
    end

    def report_mirror_error(error, record)
      Rails.error.report(
        error,
        handled: true,
        context: {
          source: "legacy_redis_state_mirror",
          record_type: record.class.name,
          name: record.name,
        },
      )
    end

    def advisory_lock_sql(function)
      "SELECT #{function}(#{ADVISORY_LOCK_KEY.join(', ')})"
    end

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
