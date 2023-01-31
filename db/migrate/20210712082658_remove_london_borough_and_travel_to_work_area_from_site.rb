# frozen_string_literal: true

class RemoveLondonBoroughAndTravelToWorkAreaFromSite < ActiveRecord::Migration[6.1]
  def change
    change_table :site, bulk: true do |t|
      t.remove :travel_to_work_area, type: :string
      t.remove :london_borough, type: :string
    end
  end
end
