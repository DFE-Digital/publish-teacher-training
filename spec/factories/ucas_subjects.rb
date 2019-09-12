# == Schema Information
#
# Table name: ucas_subject
#
#  id           :integer          not null, primary key
#  subject_name :text
#  subject_code :text             not null
#

FactoryBot.define do
  factory :ucas_subject do
    sequence(:subject_code, &:to_s)
    subject_name { Faker::ProgrammingLanguage.name }

    trait :secondary do
      subject_name { 'Secondary' }
      subject_code { '05' }
    end

    trait :primary do
      subject_name { 'Primary' }
      subject_code { '00' }
    end

    trait :mathematics do
      subject_name { 'Mathematics' }
      subject_code { 'G1' }
    end

    factory :further_education_subject do
      subject_name { 'Further Education' }
    end

    trait :english do
      subject_name { 'English' }
      subject_code { 'E' }
    end

    factory :send_subject do
      subject_name { 'Special Educational Needs' }
      subject_code { 'U3' }
    end
  end
end
