# frozen_string_literal: true

FactoryBot.define do
  factory :provider_school, class: "Provider::School" do
    provider
    gias_school
    site_code { "-" }

    trait :additional do
      site_code { "A" }
    end
  end
end
