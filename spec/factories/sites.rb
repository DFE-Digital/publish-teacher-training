FactoryBot.define do
  factory :site do
    location_name { "Main Site" + rand(1_000_000).to_s }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    region_code { "london" }
    urn { Faker::Number.number(digits: [5, 6].sample) }
    uuid { Faker::Internet.uuid }

    sequence(:code) { |n| "A#{n}" }

    provider

    transient do
      age { nil }
    end

    after(:build) do |site, evaluator|
      if evaluator.age.present?
        site.created_at = evaluator.age
        site.updated_at = evaluator.age
      end
    end
  end
end
