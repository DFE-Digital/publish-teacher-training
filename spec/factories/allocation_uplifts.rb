FactoryBot.define do
  factory :allocation_uplift do
    association :allocation, number_of_places: 1
    uplifts { 1 }
  end
end
