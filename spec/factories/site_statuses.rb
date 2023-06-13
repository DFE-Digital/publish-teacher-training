# frozen_string_literal: true

FactoryBot.define do
  factory :site_status do
    association :course, study_mode: :full_time
    association(:site)
    publish { 'N' }
    vac_status { :full_time_vacancies }
    status { 'running' }

    transient do
      provider { build(:provider) }
    end

    trait :findable do
      running
      published
    end

    trait :non_findable do
      status { %i[discontinued new_status suspended].sample }
      publish { %i[published unpublished].sample }
    end
  end
end
