# frozen_string_literal: true

class RemoveLegacyRedisSyncTracking < ActiveRecord::Migration[8.1]
  def change
    remove_column :feature_flag_state, :legacy_redis_synced_at, :datetime, if_exists: true
    remove_column :site_setting, :legacy_redis_synced_at, :datetime, if_exists: true
  end
end
