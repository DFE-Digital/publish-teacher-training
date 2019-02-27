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
    association(:provider, course_count: 0)
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

    trait :resulting_in_qts do
      qualification { :qts }
    end

    trait :resulting_in_pgce_with_qts do
      qualification { :pgce_with_qts }
    end

    trait :resulting_in_pgde_with_qts do
      qualification { :pgde_with_qts }
    end

    trait :resulting_in_pgce do
      qualification { :pgce }
    end

    trait :resulting_in_pgde do
      qualification { :pgde }
    end
  end
end
