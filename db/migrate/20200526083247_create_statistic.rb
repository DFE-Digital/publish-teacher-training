class CreateStatistic < ActiveRecord::Migration[6.0]
  def change
    create_table :statistic do |t|
      t.jsonb "json_data", null: false
      t.timestamps
    end
  end
end
