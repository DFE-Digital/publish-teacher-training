class AddWebsiteToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :provider, :website, :text
  end
end
