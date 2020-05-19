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
