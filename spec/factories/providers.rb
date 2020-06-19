FactoryBot.define do
  factory :provider do
    provider_name { "ACME SCITT" + rand(1000000).to_s }

    sequence(:provider_code) { |n| "A#{n}" }

    trait :with_anonymised_data do
      sequence(:provider_code) do |n|
        "A#{(Provider.where("provider_code like 'A%'").pluck(:provider_code).map { |e| e.slice(1..-1) }.select { |e| e.match(/^\d+$/) }.map(&:to_i).max || 0) + n}"
      end
    end

    address1 { Faker::Address.street_address }
    address2 { Faker::Address.community }
    address3 { Faker::Address.city }
    address4 { Faker::Address.state }
    postcode { Faker::Address.postcode }
    contact_name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    website { Faker::Internet.url }
    provider_type { :lead_school }
    accrediting_provider { "N" }
    region_code { "london" }
    organisations { [create(:organisation, :with_user)] }
    association :recruitment_cycle, strategy: :find_or_create

    train_with_us { Faker::Lorem.sentence.to_s }
    train_with_disability { Faker::Lorem.sentence.to_s }
    accrediting_provider_enrichments { nil }


    trait :university do
      provider_type { :university }
      accrediting_provider { "Y" }
    end

    trait :scitt do
      provider_type { :scitt }
      accrediting_provider { "Y" }
    end

    trait :accredited_body do
      provider_type { %i[university scitt].sample }
      accrediting_provider { "Y" }
    end

    transient do
      changed_at           { nil }
      skip_associated_data { false }
    end

    after(:create) do |provider, evaluator|
      # Strangely, changed_at doesn't get set if we don't do this, even though
      # updated_at does. Maybe this is because we've added changed_at to
      # timestamp_attributes_for_update but FactoryBot doesn't actually
      # recognise it.
      if evaluator.changed_at.present?
        provider.update changed_at: evaluator.changed_at
      end
    end

    trait :next_recruitment_cycle do
      recruitment_cycle { find_or_create :recruitment_cycle, :next }
    end

    trait :discarded do
      discarded_at { Time.now.utc }
    end

    trait :previous_recruitment_cycle do
      recruitment_cycle { find_or_create :recruitment_cycle, :previous }
    end

    trait :published_scitt do
      transient do
        identifier { "published_scitt" }
      end

      provider_name { "#{identifier} provider name" }
    end
  end
end
