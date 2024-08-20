# frozen_string_literal: true

class AddSelectableSchoolPlacementsOnProvider < ActiveRecord::Migration[7.1]
  def change
    add_column :provider, :selectable_school, :boolean, default: false, null: false
  end
end
