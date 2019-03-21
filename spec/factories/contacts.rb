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

FactoryBot.define do
  factory :contact do
    provider
    type { 'admin' }
  end
end
