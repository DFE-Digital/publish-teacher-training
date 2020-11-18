class AddUuidOsspExtension < ActiveRecord::Migration[6.0]
  def up
    enable_extension "uuid-ossp" unless extension_enabled?("uuid-ossp")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
