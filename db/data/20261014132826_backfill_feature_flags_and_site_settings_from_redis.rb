# frozen_string_literal: true

class BackfillFeatureFlagsAndSiteSettingsFromRedis < ActiveRecord::Migration[8.1]
  # Feature flags and the Find cycle schedule move from the worker Redis to the
  # database. Copies the live values so no flag resets and the cycle mode is
  # kept. Environments without a worker Redis (local, CI) have nothing to copy.
  def up
    return if ENV["REDIS_WORKER_URL"].blank?

    LegacyRedisState.backfill_database
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
