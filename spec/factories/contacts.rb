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
