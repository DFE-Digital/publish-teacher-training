# frozen_string_literal: true

class DeleteMaintenanceBannerFeatureFlag < ActiveRecord::Migration[8.1]
  # The maintenance_banner flag is removed from FeatureFlags.all, so nothing
  # reads its row or its legacy Redis key. LegacyRedisState only syncs listed
  # flags, so neither comes back once deleted. The Redis key is harmless, so a
  # Redis error does not stop the deploy.
  def up
    FeatureFlagState.where(name: "maintenance_banner").delete_all

    begin
      RedisClient.current.del("#{LegacyRedisState::FEATURE_FLAG_PREFIX}maintenance_banner")
    rescue Redis::BaseError => e
      Sentry.capture_exception(e)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
