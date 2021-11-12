FactoryBot.define do
  factory :allocation do
    association :accredited_body, factory: %i(provider accredited_body)
    association :provider
    number_of_places { 0 }
    association :recruitment_cycle, :current_allocation, strategy: :find_or_create

    provider_code { provider.provider_code }
    accredited_body_code { accredited_body.provider_code }

    trait :repeat do
      request_type { "repeat" }
    end
    trait :declined do
      request_type { "declined" }
    end
    trait :initial do
      request_type { "initial" }
    end
    trait :with_allocation_uplift do
      association :allocation_uplift
    end
  end
end
