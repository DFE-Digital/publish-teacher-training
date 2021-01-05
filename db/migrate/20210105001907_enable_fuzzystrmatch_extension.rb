class EnableFuzzystrmatchExtension < ActiveRecord::Migration[6.0]
  def up
    enable_extension "fuzzystrmatch" unless extension_enabled?("fuzzystrmatch")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
