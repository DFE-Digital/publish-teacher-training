# frozen_string_literal: true

# Users are hard-deleted now, so remove any leftover soft-deleted users
# before the unused discarded_at column is dropped.
class DeleteDiscardedUsers < ActiveRecord::Migration[8.1]
  def up
    User.where.not(discarded_at: nil).find_each(&:destroy!)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
