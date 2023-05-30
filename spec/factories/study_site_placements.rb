# frozen_string_literal: true

FactoryBot.define do
  factory :study_site_placements do
    association(:course)
    association(:site)
  end
end
