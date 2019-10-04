class AddContactProviderFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :contact, :provider, name: "fk_contact_provider"
  end
end
