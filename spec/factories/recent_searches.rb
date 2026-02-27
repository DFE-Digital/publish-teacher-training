FactoryBot.define do
  factory :recent_search do
    association :find_candidate, factory: :candidate
    subjects { [] }
    search_attributes { {} }
  end
end
