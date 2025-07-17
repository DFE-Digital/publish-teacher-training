FactoryBot.define do
  factory :import do
    trait :register_schools do
      short_summary { { schools_added_count: 0, providers_not_found_count: 0 } }
      full_summary { { meta: short_summary, groups: [] } }
      import_type { :register_schools }
    end
  end
end
