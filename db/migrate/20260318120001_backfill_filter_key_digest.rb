class BackfillFilterKeyDigest < ActiveRecord::Migration[8.0]
  def up
    RecentSearch.find_each(&:save!)
    Candidate::EmailAlert.find_each(&:save!)
  end

  def down
    # No-op: removing the column is handled by rolling back the previous migration
  end
end
