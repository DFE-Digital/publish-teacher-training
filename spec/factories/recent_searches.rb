FactoryBot.define do
  factory :recent_search do
    association :candidate
    subjects { [] }
    search_attributes { {} }
  end
end
