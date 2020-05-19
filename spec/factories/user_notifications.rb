FactoryBot.define do
  factory :user_notification do
    association :user
    association :provider
  end
end
