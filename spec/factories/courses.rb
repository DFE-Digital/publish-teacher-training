# == Schema Information
#
# Table name: course
#
#  id                      :integer          not null, primary key
#  age_range               :text
#  course_code             :text
#  name                    :text
#  profpost_flag           :text
#  program_type            :text
#  qualification           :integer          not null
#  start_date              :datetime
#  study_mode              :text
#  accrediting_provider_id :integer
#  provider_id             :integer          default(0), not null
#  modular                 :text
#  english                 :integer
#  maths                   :integer
#  science                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

FactoryBot.define do
  factory :course do
    sequence(:course_code) { |n| "C#{n}D3" }
    name { Faker::ProgrammingLanguage.name }
    qualification { :pgce_with_qts }
    association(:provider)
    resulting_in_pgce_with_qts

    transient do
      age { nil }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
      end
    end

    trait :in_further_education do
      after(:build) do |course|
        course.subjects << create(:futher_education_subject)
      end
    end

    trait :marked_as_pgde do
      after(:build) do |course|
        create(:pgde_course, provider_code: course.provider.provider_code, course_code: course.course_code)
      end
    end

    trait :resulting_in_qts do
      profpost_flag { :recommendation_for_qts }
    end

    trait :resulting_in_pgce_with_qts do
      profpost_flag { %i[professional postgraduate professional_postgraduate].sample }
    end

    trait :resulting_in_pgde_with_qts do
      marked_as_pgde
    end

    trait :resulting_in_pgce do
      in_further_education
      profpost_flag { %i[professional postgraduate professional_postgraduate].sample }
    end

    trait :resulting_in_pgde do
      marked_as_pgde
      in_further_education
    end
  end
end
