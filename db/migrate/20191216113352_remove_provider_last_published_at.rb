# rubocop:disable Rails/ReversibleMigration
class RemoveProviderLastPublishedAt < ActiveRecord::Migration[6.0]
  def change
    remove_column :provider, :last_published_at
  end
end
# rubocop:enable Rails/ReversibleMigration
