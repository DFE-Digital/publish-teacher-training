class AssignProviderNameToContacts < ActiveRecord::Migration[6.0]
  def change
    ucas_contacts_without_name = Contact.where(name: nil)
    ucas_contacts_without_name.each do |contact|
      contact.update(name: contact.provider.contact_name, telephone: contact.provider.telephone)
    end
  end
end
