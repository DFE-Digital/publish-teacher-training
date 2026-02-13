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

    transient do
      changed_at           { nil }
      skip_associated_data { false }
    end

    after(:create) do |provider, evaluator|
      # Problem: The `changed_at` column has a UNIQUE index (index_provider_on_changed_at)
      # and its DB default is `timezone('utc', now())`. PostgreSQL's `now()` returns
      # the *transaction start time*, so every INSERT within the same transaction (or
      # rapid sequential inserts that share the same statement timestamp) produces the
      # same changed_at value — violating the unique constraint.
      #
      # FactoryBot doesn't auto-set changed_at (it's not a standard Rails timestamp),
      # so without this hook the DB default kicks in and collisions happen whenever a
      # test creates more than one provider.
      #
      # Fix: always set changed_at explicitly, using the provider's unique DB id as a
      # microsecond offset to guarantee uniqueness.
      #
      # Why Rational and not Integer#microseconds?
      #   ActiveSupport (Rails 8) does NOT define `Integer#microseconds`. The method
      #   simply doesn't exist, so `provider.id.microseconds` raises NoMethodError.
      #   `Rational(id, 1_000_000)` produces an exact fractional second that Ruby's
      #   Time correctly adds as a sub-second offset:
      #
      #     Time.current + Rational(3, 1_000_000)  →  ...14:05:37.072986  (+3µs)
      #
      unique_changed_at = evaluator.changed_at || (Time.current + Rational(provider.id, 1_000_000))
      provider.update_column(:changed_at, unique_changed_at)
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
