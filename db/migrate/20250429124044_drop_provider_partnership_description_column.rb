class DropProviderPartnershipDescriptionColumn < ActiveRecord::Migration[8.0]
  def change
    remove_column(:provider_partnership, :description, :text, if_exists: true)
  end
end
