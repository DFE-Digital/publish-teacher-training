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
    association(:provider, course_count: 0)
    study_mode { :full_time }
    resulting_in_pgce_with_qts

    with_study_mode_as_full_time

    trait :skips_validate do
      to_create { |instance| instance.save(validate: false) }
    end

    transient do
      age { nil }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
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

    trait :with_study_mode_as_full_time do
      study_mode { :full_time }
    end

    trait :with_study_mode_as_part_time do
      study_mode { :part_time }
    end

    trait :with_study_mode_as_full_time_or_part_time do
      study_mode { :full_time_or_part_time }
    end

    factory :course_with_site_statuses do
      with_study_mode_as_full_time_or_part_time

      transient do
        site_statuses_traits {
          [
            [:findable],
            [:with_any_vacancy],
            [],
            [:applications_being_accepted_now],
            [:applications_being_accepted_in_future]
          ]
        }
      end

      after(:create) do |course, evaluator|
        evaluator.site_statuses_traits.each do |traits|
          create(:site_status, *traits, course: course)
        end
      end
    end
  end
end
