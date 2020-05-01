class AddMagicLinkTokensToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :user, bulk: true do |table|
      table.add_column :magic_link_token, :string, unique: true
      table.add_column :magic_link_token_sent_at, :datetime
    end
  end
end
