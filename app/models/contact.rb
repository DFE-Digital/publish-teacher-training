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

class Contact < ApplicationRecord
  self.inheritance_column = "_unused"

  include TouchProvider

  belongs_to :provider

  audited associated_with: :provider

  validates :name, presence: true
  validates :email, email: true, presence: true
  validates :telephone, phone: true, allow_nil: true

  enum type: {
    admin: "admin",
         utt: "utt",
         web_link: "web_link",
         fraud: "fraud",
         finance: "finance",
  },
       _suffix: "contact"
end
