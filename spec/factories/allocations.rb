FactoryBot.define do
  factory :allocation do
    association :accredited_body, factory: %i(provider accredited_body)
    association :provider
    number_of_places { 0 }
    recruitment_cycle { RecruitmentCycle.current }
  end
end
