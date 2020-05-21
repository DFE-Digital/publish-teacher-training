FactoryBot.define do
  factory :allocation do
    association :accredited_body, factory: %i(provider accredited_body)
    association :provider
    number_of_places { 0 }
    recruitment_cycle { RecruitmentCycle.current }
    trait :repeat do
      request_type { "repeat" }
    end
    trait :declined do
      request_type { "declined" }
    end
    trait :initial do
      request_type { "initial" }
    end
  end
end
