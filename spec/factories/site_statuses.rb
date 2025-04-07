# frozen_string_literal: true

FactoryBot.define do
  factory :site_status do
    course { association :course, study_mode: :full_time }
    site
    publish { "N" }
    vac_status { :full_time_vacancies }
    status { "running" }

    transient do
      any_vancancy { false }
      provider { build(:provider) }
    end

    trait :with_any_vacancy do
      any_vancancy { true }
    end

    trait :findable do
      running
      published
    end
  end
end
