class UpdateProvidersWithUCASContactsChangedAt < ActiveRecord::Migration[6.0]
  def change
    providers = Provider.select { |provider| provider.contacts.any? }
    providers.each do |provider_with_contacts|
      provider_with_contacts.update(changed_at: Time.zone.now)
    end
  end
end
