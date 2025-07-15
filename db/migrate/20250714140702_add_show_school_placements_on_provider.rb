class AddShowSchoolPlacementsOnProvider < ActiveRecord::Migration[8.0]
  def change
    add_column :provider, :show_school, :boolean, default: false, null: false
  end
end
