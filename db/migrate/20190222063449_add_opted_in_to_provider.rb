class AddOptedInToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :provider, :opted_in, :boolean, default: false
  end
end
