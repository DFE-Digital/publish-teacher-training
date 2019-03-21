class AddProviderUCASPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_ucas_preference do |t|
      t.integer :provider_id, null: false
      t.text :type_of_gt12
      t.text :send_application_alerts
      t.text :application_alert_email
      t.text :gt12_response_destination

      t.index :provider_id

      t.timestamps
    end
  end
end
