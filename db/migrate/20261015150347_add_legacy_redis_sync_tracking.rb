class AddLegacyRedisSyncTracking < ActiveRecord::Migration[8.1]
  def up
    add_column :feature_flag_state, :legacy_redis_synced_at, :datetime
    add_column :site_setting, :legacy_redis_synced_at, :datetime

    safety_assured do
      execute <<~SQL
        UPDATE feature_flag_state
        SET legacy_redis_synced_at = updated_at;

        UPDATE site_setting
        SET legacy_redis_synced_at = updated_at;
      SQL
    end
  end

  def down
    remove_column :feature_flag_state, :legacy_redis_synced_at
    remove_column :site_setting, :legacy_redis_synced_at
  end
end
