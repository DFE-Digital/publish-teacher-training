FactoryBot.define do
  factory :banner do
    sequence(:name) { |n| "Banner #{n}" }
    title { "Important" }
    heading { "Something has changed" }
    display_on_publish { true }
  end
end
