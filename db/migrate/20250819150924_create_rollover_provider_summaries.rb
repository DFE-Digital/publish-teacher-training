class CreateRolloverProviderSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :rollover_provider_summary do |t|
      t.bigint :provider_id, null: false
      t.string :provider_code, null: false
      t.string :provider_name
      t.bigint :target_recruitment_cycle_id, null: false
      t.string :status, null: false
      t.json :summary_data
      t.text :error_message
      t.decimal :execution_time_seconds, precision: 10, scale: 3

      t.index %i[provider_code target_recruitment_cycle_id], unique: true, name: "idx_rollover_provider_unique"
      t.index :status
      t.index :target_recruitment_cycle_id

      t.timestamps
    end

    add_foreign_key :rollover_provider_summary, :provider, column: :provider_id
    add_foreign_key :rollover_provider_summary, :recruitment_cycle, column: :target_recruitment_cycle_id
  end
end
