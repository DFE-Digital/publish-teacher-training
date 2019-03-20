# == Schema Information
#
# Table name: contact
#
#  id          :bigint(8)        not null, primary key
#  provider_id :integer          not null
#  type        :text
#  name        :text
#  email       :text
#  telephone   :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Contact < ApplicationRecord
  belongs_to :provider

  enum type: {
         admin:  'admin',
         utt: 'utt',
         web_link: 'web_link',
         fraud: 'fraud',
         finance: 'finance'
       },
       _suffix: 'contact'
end
