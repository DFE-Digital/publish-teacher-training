class AddUniqueIndexOnActiveEmailAlertFilterKeyDigest < ActiveRecord::Migration[8.0]
  def change
    remove_index :candidate_email_alerts, :filter_key_digest
    add_index :candidate_email_alerts, %i[candidate_id filter_key_digest],
              unique: true,
              where: "unsubscribed_at IS NULL",
              name: "idx_unique_active_email_alert_per_candidate_filter"
  end
end
