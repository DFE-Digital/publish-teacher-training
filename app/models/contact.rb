# == Schema Information
#
# Table name: contact
#
#  id          :bigint           not null, primary key
#  provider_id :integer          not null
#  type        :text             not null
#  name        :text
#  email       :text
#  telephone   :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Contact < ApplicationRecord
  self.inheritance_column = "_unused"

  include TouchProvider

  belongs_to :provider

  audited associated_with: :provider

  validates :name, presence: true
  validates :email, email: true, presence: true
  validates :telephone, phone: { message: "^Enter a valid telephone number" }, allow_nil: true

  enum type: {
    admin: "admin",
         utt: "utt",
         web_link: "web_link",
         fraud: "fraud",
         finance: "finance",
  },
       _suffix: "contact"
end
