class AddTravelToWorkAreaColumnToSitesTable < ActiveRecord::Migration[6.0]
  def change
    change_table :site, bulk: true do |t|
      t.string :travel_to_work_area
      t.string :london_borough
    end
  end
end
