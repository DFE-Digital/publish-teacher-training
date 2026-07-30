# frozen_string_literal: true

FactoryBot.define do
  factory :site do
    location_name { "Main Site#{rand(1_000_000)}" }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.street_name }
    town { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    region_code { "london" }
    sequence(:urn, 100_000, &:to_s)
    uuid { Faker::Internet.uuid }
    site_type { "school" }

    sequence(:code) { |n| "A#{n}" }

    provider

    transient do
      age { nil }
    end

    # Only needed by specs exercising Site.with_available_gias_school, i.e. the
    # legacy rollover copiers. An existing row for the urn is never replaced, so
    # a spec wanting a closed school creates it first.
    trait :with_gias_school do
      after(:build) do |site|
        create(:gias_school, :open, urn: site.urn) unless GiasSchool.exists?(urn: site.urn)
      end
    end

    trait :study_site do
      site_type { "study_site" }
    end

    trait :main_site do
      code { "-" }
      urn { nil }
    end

    trait :discarded do
      discarded_at { Time.zone.now }
    end

    after(:build) do |site, evaluator|
      if evaluator.age.present?
        site.created_at = evaluator.age
        site.updated_at = evaluator.age
      end
    end
  end
end
