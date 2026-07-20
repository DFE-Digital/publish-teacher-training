# frozen_string_literal: true

FactoryBot.define do
  factory :provider_school, class: "Provider::School" do
    provider
    gias_school
    # Walks "A", "B", ... "Z", "AA", ... via String#next
    sequence(:site_code, "A")
    uuid { SecureRandom.uuid }

    trait :main_site do
      site_code { Provider::School::MAIN_SITE_CODE }
    end
  end
end
