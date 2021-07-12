class RemoveLondonBoroughAndTravelToWorkAreaFromSite < ActiveRecord::Migration[6.1]
  def change
    remove_column :site, :travel_to_work_area, :string
    remove_column :site, :london_borough, :string
  end
end
