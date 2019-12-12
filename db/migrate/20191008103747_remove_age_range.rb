# rubocop:disable Rails/ReversibleMigration
class RemoveAgeRange < ActiveRecord::Migration[6.0]
  def change
    remove_column :course, :age_range
  end
end
# rubocop:enable Rails/ReversibleMigration
