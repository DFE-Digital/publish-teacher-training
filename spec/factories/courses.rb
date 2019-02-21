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
    qualification { 1 }
    association(:provider)

    transient do
      age { nil }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
      end
    end
  end

  factory :course_with_qualication, parent: :course do
    transient do
      have_pgde { false }
      have_fe_subject { false }
    end

    trait :with_further_education_subject do
      transient do
        have_fe_subject { true }
      end
    end

    trait :with_pgde_course do
      transient do
        have_pgde { true }
      end
    end

    # #[:qts] # 'QTS'
    # ["recommendation_for_qts", :not_pgde, :not_fe]        => %i[qts],

    factory :course_with_qts_qualication do
      profpost_flag { :recommendation_for_qts }
    end


    factory :course_with_pgce_qts_qualication do
      profpost_flag { %i[professional postgraduate professional_postgraduate].sample }
    end

    factory :course_with_pgde_qts_qualication do
      with_pgde_course
      profpost_flag { %i[recommendation_for_qts professional postgraduate professional_postgraduate].sample }
    end

    factory :course_with_pgce_qualication do
      with_further_education_subject
      profpost_flag { %i[professional postgraduate professional_postgraduate].sample }
    end

    factory :course_with_pgde_qualication do
      with_pgde_course
      with_further_education_subject
      profpost_flag { %i[recommendation_for_qts professional postgraduate professional_postgraduate].sample }
    end

    after(:build) do |course, evaluator|
      if evaluator.have_pgde
        create(:pgde_course, provider_code: course.provider.provider_code, course_code: course.course_code)
      end

      if evaluator.have_fe_subject
        course.subjects << create(:futher_education_subject)
      end
    end
  end
end
