# frozen_string_literal: true

# Feature flags and site settings used to live in the worker Redis. The
# database is now the source of truth, but every change is also written to
# Redis so the previous release, which still reads Redis, can be redeployed.
# Delete this class when Redis is removed. See guides/redis-application-state.md.
class LegacyRedisState
  FEATURE_FLAG_PREFIX = "feature_flags_"
  # Also taken by db/scripts/preserve_environment_state_before_restore.sql.
  ADVISORY_LOCK_KEY = [20_261_015, 6_581].freeze

  class << self
    # Saves a FeatureFlagState or SiteSetting, then copies it to Redis.
    # A failed Redis write leaves the row marked as unsynced, and the next
    # web boot retries it.
    def save(model, name:, **attributes)
      with_state_lock do
        record = model.find_or_initialize_by(name:)
        record.update!(**attributes, legacy_redis_synced_at: nil)

        begin
          push_to_redis(record)
        rescue Redis::BaseError, ActiveRecord::ActiveRecordError => e
          report_redis_error(e, record)
        end

        record
      end
    end

    # Runs before every web boot. Pushes any unsynced database changes, then
    # copies Redis into the database to pick up changes the previous release
    # made while it was running. A missing Redis key means the default state,
    # but an empty Redis must not wipe the database (that looks the same as a
    # flush). Redis errors are reported and the boot continues on database state.
    def backfill_database
      with_state_lock do
        push_unsynced_to_redis

        flags = flags_from_redis
        settings = settings_from_redis

        ActiveRecord::Base.transaction do
          apply_redis_rows(FeatureFlagState, flags, changed_columns: %i[active])
          apply_redis_rows(SiteSetting, settings, changed_columns: %i[value])
        end

        { feature_flags: flags.size, site_settings: settings.size }
      end
    rescue Redis::BaseError => e
      report_reconcile_error(e)
      { feature_flags: 0, site_settings: 0, skipped: :redis_unavailable }
    end

    # Run before redeploying a release that reads Redis.
    def sync_to_redis
      with_state_lock do
        flags = FeatureFlagState.where(name: feature_names).index_by(&:name)
        settings = SiteSetting.where(name: SiteSetting::NAMES).index_by(&:name)

        feature_names.each { |name| export(flags[name], key: feature_flag_key(name)) }
        SiteSetting::NAMES.each { |name| export(settings[name], key: name) }

        { feature_flags: flags.size, site_settings: settings.size }
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

    # Stops setters, web boot and database restores from overwriting each
    # other's changes.
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

  private

    def push_to_redis(record)
      case record
      when FeatureFlagState
        redis.set(feature_flag_key(record.name), { state: record.active, updated_at: record.updated_at }.to_json)
      when SiteSetting
        redis.set(record.name, record.value)
      end

      record.update_column(:legacy_redis_synced_at, record.updated_at)
    end

    def push_unsynced_to_redis
      [FeatureFlagState, SiteSetting].each do |model|
        model.where(legacy_redis_synced_at: nil).find_each { |record| push_to_redis(record) }
      end
    end

    def export(record, key:)
      if record
        push_to_redis(record)
      else
        redis.del(key)
      end
    end

    def flags_from_redis
      feature_names.filter_map do |name|
        raw = redis.get(feature_flag_key(name))
        next if raw.blank?

        data = JSON.parse(raw)
        changed_at = data["updated_at"].present? ? Time.zone.parse(data["updated_at"]) : Time.zone.now

        { name:, active: data["state"] == true, created_at: changed_at, updated_at: changed_at, legacy_redis_synced_at: changed_at }
      end
    end

    # Redis does not store when a setting changed, so keep the database
    # timestamp unless the value is different.
    def settings_from_redis
      existing = SiteSetting.where(name: SiteSetting::NAMES).index_by(&:name)

      SiteSetting::NAMES.filter_map do |name|
        value = redis.get(name)
        next if value.blank?

        current = existing[name]
        changed_at = current&.value == value ? current.updated_at : Time.zone.now

        { name:, value:, created_at: current&.created_at || changed_at, updated_at: changed_at, legacy_redis_synced_at: changed_at }
      end
    end

    # An empty Redis import with existing database rows is treated as a flush
    # or misconfiguration, not "everything is default". Partial Redis state
    # still deletes names that are absent (missing key = default).
    def apply_redis_rows(model, rows, changed_columns:)
      if rows.empty? && model.exists?
        report_empty_redis_skip(model)
        return
      end

      replace_rows(model, rows, changed_columns:)
    end

    def replace_rows(model, rows, changed_columns:)
      model.where.not(name: rows.pluck(:name)).delete_all
      return if rows.empty?

      model.upsert_all(
        rows,
        unique_by: :name,
        update_only: changed_columns + %i[updated_at legacy_redis_synced_at],
        record_timestamps: false,
      )
    end

    def report_redis_error(error, record)
      Rails.error.report(
        error,
        handled: true,
        context: { source: "legacy_redis_state_mirror", record_type: record.class.name, name: record.name },
      )
    end

    def report_reconcile_error(error)
      Rails.error.report(
        error,
        handled: true,
        context: { source: "legacy_redis_state_reconcile" },
      )
    end

    def report_empty_redis_skip(model)
      Rails.error.report(
        StandardError.new("Skipped Redis→#{model.table_name} replace: Redis had no keys but the database has rows"),
        handled: true,
        context: { source: "legacy_redis_state_reconcile", table: model.table_name },
      )
    end

    def advisory_lock_sql(function)
      "SELECT #{function}(#{ADVISORY_LOCK_KEY.join(', ')})"
    end

    def feature_names
      FeatureFlag.features.keys.map(&:to_s)
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
