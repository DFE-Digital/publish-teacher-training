class ChangeContactTypesToBeUniqueToProvider < ActiveRecord::Migration[5.2]
  def change
    add_index :contact, %i[provider_id type], unique: true
  end
end
