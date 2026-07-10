# frozen_string_literal: true

FactoryBot.define do
  factory :course_school, class: "Course::School" do
    course
    gias_school
    # Walks "A", "B", ... "Z", "AA", ... via String#next
    sequence(:site_code, "A")
    provider_school do
      Provider::School.find_by(provider: course.provider, gias_school:, site_code:) ||
        association(:provider_school, provider: course.provider, gias_school:, site_code:)
    end

    trait :main_site do
      site_code { Provider::School::MAIN_SITE_CODE }
    end
  end
end
