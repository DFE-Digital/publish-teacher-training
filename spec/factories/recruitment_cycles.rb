# frozen_string_literal: true

FactoryBot.define do
  factory :recruitment_cycle do
    year { Settings.current_recruitment_cycle_year }
    application_start_date { DateTime.new(year.to_i - 1, 10, 1) }
    application_end_date { DateTime.new(year.to_i, 9, 30) }
    available_in_publish_from { application_start_date.to_date - 1.month }
    available_for_support_users_from { available_in_publish_from - 1.week }

    trait :previous do
      year { (Settings.current_recruitment_cycle_year.to_i - 1).to_s }
    end

    trait :next do
      year { (Settings.current_recruitment_cycle_year.to_i + 1).to_s }
    end
  end
end
