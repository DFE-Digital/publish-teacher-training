class AddMagicLinkTokensToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :user, bulk: true do |table|
      table.string :magic_link_token, unique: true
      table.datetime :magic_link_token_sent_at
    end
  end
end
