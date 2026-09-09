class SetSolidCacheEntriesUnlogged < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    safety_assured { execute "ALTER TABLE solid_cache_entries SET UNLOGGED" }
  end

  def down
    safety_assured { execute "ALTER TABLE solid_cache_entries SET LOGGED" }
  end
end
