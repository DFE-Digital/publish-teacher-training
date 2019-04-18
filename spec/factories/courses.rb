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
      subject_count      { 1 }
      subjects           { build_list(:subject, subject_count) }
      with_site_statuses { [] }
      with_enrichments { [] }
      age { nil }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end
    end

    after(:create) do |course, evaluator|
      course.subjects << evaluator.subjects

      evaluator.with_site_statuses.each do |traits|
        attrs = { course: course }
        if traits == [:default]
          create(:site_status, attrs)
        else
          create(:site_status, *traits, attrs)
        end
      end

      evaluator.with_enrichments.each do |trait, attributes = {}|
        defaults = {
          ucas_course_code: course.course_code,
          provider_code: course.provider.provider_code,
        }
        create(:course_enrichment, trait, attributes.merge(defaults))
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

    trait :primary do
      age_range { 'P' }
    end

    trait :secondary do
      age_range { 'S' }
    end
  end
end
