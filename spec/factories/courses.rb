# == Schema Information
#
# Table name: course
#
#  accrediting_provider_code :text
#  accrediting_provider_id   :integer
#  age_range_in_years        :string
#  applications_open_from    :date
#  changed_at                :datetime         not null
#  course_code               :text
#  created_at                :datetime         not null
#  discarded_at              :datetime
#  english                   :integer
#  id                        :integer          not null, primary key
#  is_send                   :boolean          default(FALSE)
#  level                     :string
#  maths                     :integer
#  modular                   :text
#  name                      :text
#  profpost_flag             :text
#  program_type              :text
#  provider_id               :integer          default(0), not null
#  qualification             :integer          not null
#  science                   :integer
#  start_date                :datetime
#  study_mode                :text
#  updated_at                :datetime         not null
#
# Indexes
#
#  IX_course_accrediting_provider_id          (accrediting_provider_id)
#  IX_course_provider_id_course_code          (provider_id,course_code) UNIQUE
#  index_course_on_accrediting_provider_code  (accrediting_provider_code)
#  index_course_on_changed_at                 (changed_at) UNIQUE
#  index_course_on_discarded_at               (discarded_at)
#

FactoryBot.define do
  factory :course do
    sequence(:course_code) { |n| "C#{n}#{(0..9).to_a.sample(2).join}" }
    name { Faker::Lorem.word }
    qualification { :pgce_with_qts }
    with_apprenticeship

    provider

    study_mode { :full_time }
    maths { :must_have_qualification_at_application_time }
    english { :must_have_qualification_at_application_time }
    science { :must_have_qualification_at_application_time }
    level { :primary }
    age_range_in_years { "3_to_7" }
    resulting_in_pgce_with_qts
    start_date { DateTime.new(provider.recruitment_cycle.year.to_i, 9, 1) }
    applications_open_from {
      Faker::Time.between(
        from: DateTime.new(provider.recruitment_cycle.year.to_i - 1, 10, 1),
        to: DateTime.new(provider.recruitment_cycle.year.to_i, 9, 29),
      )
    }

    trait :primary do
      level { :primary }
      age_range_in_years { "3_to_7" }
    end

    trait :secondary do
      age_range_in_years { "11_to_18" }
      level { :secondary }
    end

    transient do
      age { nil }
      infer_level? { false }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end

      if evaluator.infer_level? && course.subjects.present?
        subjects = course.subjects
          .reject { |s| s.type == "DiscontinuedSubject" }
          .reject { |s| s.type == "MordernLanguagesSubject" }

        if subjects.all? do |subject| subject.type == "PrimarySubject" end
          course.level = "primary"
        elsif subjects.all? do |subject| subject.type == "SecondarySubject" end
          course.level = "secondary"
        elsif subjects.all? do |subject| subject.type == "FurtherEducationSubject" end
          course.level = "further_education"
        end
      end

      if course.subjects.any?
        generate_course_title_service = Courses::GenerateCourseTitleService.new
        course.name = generate_course_title_service.execute(course: course)
      end
    end

    after(:create) do |course, evaluator|
      # This is important to retain the relationship behaviour between
      # course and it's enrichment
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end

      if course.subjects.any?
        generate_course_title_service = Courses::GenerateCourseTitleService.new
        course.name = generate_course_title_service.execute(course: course)
      end

      # We've just created a course with this provider's code, so ensure it's
      # up-to-date and has this course loaded.
      course.provider.reload
    end

    trait :infer_level do
      transient do
        infer_level? { true }
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

    trait :fee_type_based do
      program_type {
        %i[higher_education_programme school_direct_training_programme
           scitt_programme].sample
      }
    end

    trait :salary_type_based do
      program_type { %i[pg_teaching_apprenticeship school_direct_salaried_training_programme].sample }
    end

    trait :applications_open_from_not_set do
      applications_open_from { nil }
    end

    trait :deleted do
      discarded_at { Time.now - 1.days }
    end
  end
end
