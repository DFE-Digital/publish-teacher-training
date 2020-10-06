class AddFulltextIndexForProviders < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS btree_gin;"
    execute "CREATE EXTENSION IF NOT EXISTS btree_gist;"
    add_index :provider, :provider_name, using: "gin"
    add_index :provider, :provider_code, using: "gin"
  end

  def down
    remove_index :provider, :provider_name, using: "gin"
    remove_index :provider, :provider_code, using: "gin"
    execute "DROP EXTENSION IF EXISTS btree_gin;"
    execute "DROP EXTENSION IF EXISTS btree_gist;"
  end
end
