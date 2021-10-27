FactoryBot.define do
  factory :allocation_uplift do
    association :allocation
    uplifts { 1 }
  end
end
