class RenameEmailAlertToCandidateEmailAlerts < ActiveRecord::Migration[8.0]
  def change
    rename_table :email_alert, :candidate_email_alerts
  end
end
