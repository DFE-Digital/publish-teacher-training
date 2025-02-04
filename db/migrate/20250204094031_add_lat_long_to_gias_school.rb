# frozen_string_literal: true

class AddLatLongToGiasSchool < ActiveRecord::Migration[8.0]
  def change
    change_table :gias_school, bulk: true do |t|
      t.column :latitude, :float
      t.column :longitude, :float
    end
  end
end
