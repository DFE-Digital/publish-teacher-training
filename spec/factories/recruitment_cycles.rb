FactoryBot.define do
  factory :recruitment_cycle do
    year { Settings.current_recruitment_cycle_year }
    application_start_date { DateTime.new(year.to_i - 1, 10, 1) }
    application_end_date { DateTime.new(year.to_i, 9, 30) }

    trait :previous do
      year { (Settings.current_recruitment_cycle_year.to_i - 1).to_s }
    end

    trait :next do
      year { (Settings.current_recruitment_cycle_year.to_i + 1).to_s }
    end
  end
end
