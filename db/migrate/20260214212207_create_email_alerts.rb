# frozen_string_literal: true

class CreateEmailAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :email_alert do |t|
      t.references :candidate, null: false, foreign_key: true
      t.string :subjects, array: true, default: []
      t.float :longitude
      t.float :latitude
      t.integer :radius
      t.jsonb :search_attributes, default: {}
      t.string :location_name
      t.datetime :last_sent_at
      t.datetime :unsubscribed_at

      t.timestamps
    end

    add_index :email_alert, %i[candidate_id unsubscribed_at],
              name: "index_email_alerts_candidate_active"
    add_index :email_alert, :unsubscribed_at
  end
end
