# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    provider
    admin_type
    name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    permission_given { true }
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
