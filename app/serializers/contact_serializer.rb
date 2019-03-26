# == Schema Information
#
# Table name: contact
#
#  id          :bigint(8)        not null, primary key
#  provider_id :integer          not null
#  type        :text             not null
#  name        :text
#  email       :text
#  telephone   :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
