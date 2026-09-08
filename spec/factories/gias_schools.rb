# frozen_string_literal: true

FactoryBot.define do
  factory :gias_school do
    urn { Faker::Number.unique.number(digits: 6).to_s }
    # Unique and punctuation-free. Faker::University.name can include apostrophes
    # (e.g. West D'Amore) which smart_quotes turns into ’ on decorated pages, and
    # Capybara's check/have_content match on a substring, so random names can
    # collide or prefix each other.
    sequence(:name) { |n| sprintf("Test School %06d", n) }
    address1 { Faker::Address.street_address }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }
    status_code { GiasSchool.status_codes["open"] }
    region_code { GiasSchool.region_codes["south_west"] }

    trait :open do
      status_code { GiasSchool.status_codes["open"] }
    end

    trait :closed do
      status_code { GiasSchool.status_codes["closed"] }
    end
  end
end
