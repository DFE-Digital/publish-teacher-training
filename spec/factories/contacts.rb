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

FactoryBot.define do
  factory :contact do
    provider
    admin_type
    name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
  end

  trait :admin_type do
    type { :admin }
  end

  trait :utt_type do
    type { :utt }
  end

  trait :web_link_type do
    type { :web_link }
  end

  trait :finance_type do
    type { :finance }
  end

  trait :fraud_type do
    type { :fraud }
  end
end
