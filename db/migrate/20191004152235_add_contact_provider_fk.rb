class AddContactProviderFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :contact, :provider
  end
end
