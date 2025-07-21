class CreateDataHubProcessSummary < ActiveRecord::Migration[8.0]
  def change
    create_table :data_hub_process_summary do |t|
      t.string   :type, null: false
      t.string   :status
      t.datetime :started_at
      t.datetime :finished_at

      t.jsonb    :short_summary, null: false, default: {}
      t.jsonb    :full_summary,  null: false, default: {}

      t.timestamps
    end

    add_index :data_hub_process_summary, :type
    add_index :data_hub_process_summary, %i[id type]
    add_index :data_hub_process_summary, :started_at
    add_index :data_hub_process_summary, :finished_at
  end
end
