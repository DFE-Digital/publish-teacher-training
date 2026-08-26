FactoryBot.define do
  factory :banner do
    sequence(:name) { |n| "Banner #{n}" }
    heading { "Something has changed" }
    published_at { 1.day.ago }
    display_on_publish { true }
  end
end
