class AddChangedAtToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :provider, :changed_at, :datetime, default: -> { "timezone('utc'::text, now())" }, null: false
  end
end
