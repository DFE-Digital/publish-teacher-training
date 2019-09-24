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

  belongs_to :provider

  audited associated_with: :provider

  enum type: {
    admin: "admin",
         utt: "utt",
         web_link: "web_link",
         fraud: "fraud",
         finance: "finance",
  },
       _suffix: "contact"
end
