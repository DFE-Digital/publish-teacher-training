class AddFilterKeyDigestToSearchesAndAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_recent_search, :filter_key_digest, :string
    add_column :candidate_email_alerts, :filter_key_digest, :string

    add_index :candidate_recent_search, :filter_key_digest
    add_index :candidate_email_alerts, :filter_key_digest
  end
end
