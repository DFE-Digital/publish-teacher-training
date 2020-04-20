FactoryBot.define do
  factory :allocation do
    association :accredited_body, factory: %i(provider accredited_body)
    association :provider
  end
end
