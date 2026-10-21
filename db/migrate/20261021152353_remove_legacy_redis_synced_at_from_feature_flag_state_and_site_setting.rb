# frozen_string_literal: true

class RemoveLegacyRedisSyncedAtFromFeatureFlagStateAndSiteSetting < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :feature_flag_state, :legacy_redis_synced_at, :datetime
      remove_column :site_setting, :legacy_redis_synced_at, :datetime
    end
  end
end
