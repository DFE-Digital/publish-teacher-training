# frozen_string_literal: true

FactoryBot.define do
  factory :provider do
    provider_name { "ACME SCITT#{rand(1_000_000)}" }

    sequence(:provider_code) do |n|
      ProviderCodeGenerator.new(n).call
    end

    trait :with_anonymised_data do
      sequence(:provider_code) do |n|
        "A#{(Provider.where("provider_code like 'A%'").pluck(:provider_code).map { |e| e.slice(1..-1) }.select { |e| e.match(/^\d+$/) }.map(&:to_i).max || 0) + n}"
      end
    end

    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.street_name }
    town { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    contact_name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    website { Faker::Internet.url }
    provider_type { :lead_school }
    urn { Faker::Number.number(digits: [5, 6].sample) }
    ukprn { Faker::Number.within(range: 10_000_000..19_999_999) }
    accredited { false }
    region_code { "london" }
    association :recruitment_cycle, strategy: :find_or_create

    about_us { Faker::Lorem.sentence.to_s }
    value_proposition { Faker::Lorem.sentence.to_s }
    train_with_us { Faker::Lorem.sentence.to_s }
    train_with_disability { Faker::Lorem.sentence.to_s }
    can_sponsor_student_visa { [true, false].sample }
    can_sponsor_skilled_worker_visa { [true, false].sample }
    synonyms { Faker::Lorem.words(number: 0..3) }
    selectable_school { true }

    # The `changed_at` column has a UNIQUE index and a DB default of `now()`.
    # PostgreSQL's `now()` is stable within a transaction, so multiple INSERTs
    # in the same transaction get the same value and the INSERT itself fails.
    # A sequence ensures each provider gets a unique value in the INSERT.
    sequence(:changed_at) { |n| Time.zone.at(n).utc }

    trait :with_name do
      provider_name { "Test Name" }
    end

    trait :university do
      provider_type { :university }
      urn { nil }
    end

    trait :scitt do
      provider_type { :scitt }
      urn { nil }
    end

    trait :accredited_provider do
      provider_type { :university }
      accredited { true }
      accredited_provider_number { Faker::Number.within(range: 1000..1999) }
      urn { nil }
    end

    trait :with_users do
      users { create_list(:user, 4) }
    end

    trait :next_recruitment_cycle do
      recruitment_cycle { find_or_create :recruitment_cycle, :next }
    end

    trait :discarded do
      discarded_at { Time.zone.now }
    end

    trait :previous_recruitment_cycle do
      recruitment_cycle { find_or_create :recruitment_cycle, :previous }
    end

    trait :published_scitt do
      scitt
      transient do
        identifier { "published_scitt" }
      end

      provider_name { "#{identifier} provider name" }
    end

    factory :accredited_provider do
      provider_type { :university }
      accredited { true }
      accredited_provider_number do
        if provider_type == :scitt
          Faker::Number.within(range: 5000..5999)
        else
          Faker::Number.within(range: 1000..1999)
        end
      end
      urn { nil }
    end
  end
end
