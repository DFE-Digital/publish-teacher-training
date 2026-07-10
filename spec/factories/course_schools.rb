# frozen_string_literal: true

FactoryBot.define do
  factory :course_school, class: "Course::School" do
    course
    gias_school
    site_code { "-" }
    provider_school do
      Provider::School.find_by(provider: course.provider, gias_school:, site_code:) ||
        association(:provider_school, provider: course.provider, gias_school:, site_code:)
    end

    trait :additional do
      site_code { "A" }
    end
  end
end
