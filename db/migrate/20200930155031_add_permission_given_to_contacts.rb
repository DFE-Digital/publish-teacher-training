class AddPermissionGivenToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contact, :permission_given, :boolean, default: false
    reversible do |migration|
      migration.up { execute "update contact set permission_given = true" }
    end
  end
end
