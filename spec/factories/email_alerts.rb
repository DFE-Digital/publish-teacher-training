FactoryBot.define do
  factory :email_alert do
    association :candidate
    subjects { [] }
    search_attributes { {} }
  end
end
