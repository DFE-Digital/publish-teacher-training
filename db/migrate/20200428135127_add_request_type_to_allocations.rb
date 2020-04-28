class AddRequestTypeToAllocations < ActiveRecord::Migration[6.0]
  def change
    add_column :allocation, :request_type, :integer, default: 0
    add_index :allocation, :request_type
  end
end
