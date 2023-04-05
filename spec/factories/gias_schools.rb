# frozen_string_literal: true

FactoryBot.define do
  factory :gias_school do
    urn { Faker::Number.unique.number(digits: 6).to_s }
    name { Faker::University.name }
    address1 { Faker::Address.street_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }
    status_code { GiasSchool::ESTABLISHMENT_OPEN_STATUS_CODE }

    trait :closed do
      status_code { nil }
    end
  end
end
