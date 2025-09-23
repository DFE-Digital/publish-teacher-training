# frozen_string_literal: true

FactoryBot.define do
  factory :recruitment_cycle do
    year { Find::CycleTimetable.current_year }
    application_start_date { Find::CycleTimetable.apply_opens(year) }
    application_end_date { Find::CycleTimetable.apply_deadline(year) }
    available_in_publish_from { application_start_date.to_date - 1.month }
    available_for_support_users_from { available_in_publish_from - 1.week }

    trait :previous do
      year { Find::CycleTimetable.previous_year }
    end

    trait :next do
      year { Find::CycleTimetable.next_year }
    end
  end
end
