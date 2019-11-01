# == Schema Information
#
# Table name: contact
#
#  created_at  :datetime         not null
#  email       :text
#  id          :bigint           not null, primary key
#  name        :text
#  provider_id :integer          not null
#  telephone   :text
#  type        :text             not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_contact_on_provider_id           (provider_id)
#  index_contact_on_provider_id_and_type  (provider_id,type) UNIQUE
#

# application alert recipient has been added as a contact manually in the provider
# contact serializer (../provider_serializer.rb:38). It has not been added into
# the enum in the contact model as it's does not share the name and email attribute.
# It is simply a contact email address and is more suited to sit in the ucas
# preferences model.

class ContactSerializer < ActiveModel::Serializer
  belongs_to :provider

  attributes :type, :name, :email, :telephone
end
