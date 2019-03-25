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
    name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
  end

  trait :admin_contact do
    type { :admin }
  end

  trait :utt_contact do
    type { :utt }
  end

  trait :web_link_contact do
    type { :web_link }
  end

  trait :finance_contact do
    type { :finance }
  end

  trait :fraud_contact do
    type { :fraud }
  end
end
