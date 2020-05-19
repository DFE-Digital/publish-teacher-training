class ContactSerializer < ActiveModel::Serializer
  belongs_to :provider

  attributes :type, :name, :email, :telephone
end
