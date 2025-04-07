class RemoveUniqueIndexFromProviderChangedAt < ActiveRecord::Migration[8.0]
  def up
    remove_index :provider, name: :index_provider_on_changed_at, unique: true
  end

  def down
    add_index :provider, :changed_at, unique: true
  end
end
