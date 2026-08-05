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

    # The Provider::School half of the dual-write that accompanies a real site
    # creation, joined to the legacy site by the uuid the two share. Course
    # creation rejects any selected school whose paired row is missing, so
    # anything that creates a course from school_uuids needs this.
    #
    # after(:create), not after(:build): a site handed to `create(:provider,
    # sites: [...])` is built against the factory's own throwaway provider and
    # only reassigned when the provider saves it, so a build hook would pair the
    # school to the wrong provider.
    trait :with_provider_school do
      after(:create) do |site|
        create(:provider_school, :for_site, site:)
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
