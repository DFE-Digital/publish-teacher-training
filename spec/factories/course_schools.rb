# frozen_string_literal: true

FactoryBot.define do
  sequence(:course_school_provider_site_code, "A")

  factory :course_school, class: "Course::School" do
    course
    gias_school

    transient do
      site_code { generate(:course_school_provider_site_code) }
    end

    provider_school do
      Provider::School.find_by(provider: course.provider, gias_school:, site_code:) ||
        association(:provider_school, provider: course.provider, gias_school:, site_code:)
    end

    after(:build) do |course_school, evaluator|
      if course_school.has_attribute?(:site_code)
        course_school.site_code = evaluator.site_code || course_school.provider_school.site_code
      end
    end

    trait :main_site do
      site_code { Provider::School::MAIN_SITE_CODE }
    end
  end
end
