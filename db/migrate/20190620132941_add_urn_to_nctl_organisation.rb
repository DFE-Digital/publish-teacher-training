class AddURNToNCTLOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :nctl_organisation, :urn, :integer
  end
end
