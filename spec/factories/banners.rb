FactoryBot.define do
  factory :banner do
    sequence(:name) { |n| "Banner #{n}" }
  end
end
