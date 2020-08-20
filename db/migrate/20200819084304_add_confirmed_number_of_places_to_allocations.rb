class AddConfirmedNumberOfPlacesToAllocations < ActiveRecord::Migration[6.0]
  def change
    add_column :allocation, :confirmed_number_of_places, :integer, null: true
  end
end
