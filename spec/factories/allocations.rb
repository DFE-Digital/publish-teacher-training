FactoryBot.define do
  factory :allocation do
    association :accredited_body, factory: :provider
    association :provider
  end
end
