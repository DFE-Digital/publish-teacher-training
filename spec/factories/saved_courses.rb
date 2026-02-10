FactoryBot.define do
  factory :saved_course do
    association :candidate
    association :course
    note { nil }
  end
end
