# frozen_string_literal: true

class DropAllocations < ActiveRecord::Migration[7.0]
  def up
    drop_table :allocation_uplift
    drop_table :allocation
  end

  def down
    raise ActiveRecord::IrreversibleMigration, " The 'allocation' & 'allocation_uplift' tables was only used when PE allocation/recruitment was restricted, this is now not the case."
  end
end
