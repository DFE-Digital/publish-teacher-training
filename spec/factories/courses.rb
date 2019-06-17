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
#  changed_at              :datetime         not null
#

FactoryBot.define do
  factory :course do
    sequence(:course_code) { |n| "C#{n}D3" }
    name { Faker::ProgrammingLanguage.name }
    qualification { :pgce_with_qts }
    with_higher_education

    association(:provider)

    study_mode { :full_time }
    resulting_in_pgce_with_qts

    transient do
      age                { nil }
      enrichments        { [] }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end
    end

    after(:create) do |course, evaluator|
      # This is important to retain the relationship behaviour between
      # course and it's enrichment
      course.enrichments += evaluator.enrichments.map do |enrichment|
        enrichment.tap do |e|
          e.provider_code = course.provider.provider_code
        end
      end

      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end

      # We've just created a course with this provider's code, so ensure it's
      # up-to-date and has this course loaded.
      course.provider.reload
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

    trait :with_accrediting_provider do
      association(:accrediting_provider, factory: :provider)
    end

    trait :with_higher_education do
      program_type { :higher_education_programme }
    end

    trait :with_school_direct do
      program_type { :school_direct_training_programme }
    end

    trait :with_scitt do
      program_type { :scitt_programme }
    end

    trait :with_apprenticeship do
      program_type { :pg_teaching_apprenticeship }
    end

    trait :with_salary do
      program_type { :school_direct_salaried_training_programme }
    end

    trait :fee_type_based do
      program_type {
        %i[higher_education_programme school_direct_training_programme
           scitt_programme].sample
      }
    end

    trait :salary_type_based do
      program_type { %i[pg_teaching_apprenticeship school_direct_salaried_training_programme].sample }
    end
  end
end
