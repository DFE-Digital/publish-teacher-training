# rubocop:disable Rails/ReversibleMigration
class RemoveScittAttributeFromProvider < ActiveRecord::Migration[6.0]
  def change
    remove_column :provider, :scitt
  end
end
# rubocop:enable Rails/ReversibleMigration
