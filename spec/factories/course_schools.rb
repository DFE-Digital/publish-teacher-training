# frozen_string_literal: true

FactoryBot.define do
  factory :course_school, class: "Course::School" do
    course
    gias_school
    site_code { "-" }

    trait :additional do
      site_code { "A" }
    end
  end
end
