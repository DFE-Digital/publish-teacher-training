class AddUKPRNToNCTLOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :nctl_organisation, :ukprn, :integer
  end
end
