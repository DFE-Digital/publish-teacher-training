# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

FactoryBot.define do
  # TODO: use known subject list
  factory :subject do
    sequence(:subject_code, &:to_s)
    subject_name { Faker::ProgrammingLanguage.name }
    type {
      %w[PrimarySubject
         SecondarySubject
         FurtherEducationSubject].sample
    }

    trait :primary do
      subject_name { "Primary" }
      subject_code { "00" }
      type { "PrimarySubject" }
    end

    trait :secondary do
      type { "SecondarySubject" }
    end

    trait :primary_with_mathematics do
      subject_name { "Primary with mathematics" }
      subject_code { "01" }
      type { "PrimarySubject" }
    end

    trait :primary_with_mathematics do
      subject_name { "Primary with mathematics" }
      subject_code { "04" }
      type { :PrimarySubject }
    end

    trait :mathematics do
      subject_name { "Mathematics" }
      subject_code { "G1" }
      type { "SecondarySubject" }
    end

    trait :french do
      subject_name { "French" }
      subject_code { "F1" }
      type { "ModernLanguagesSubject" }
    end

    trait :german do
      subject_name { "German" }
      subject_code { "G2" }
      type { "ModernLanguagesSubject" }
    end

    trait :further_education do
      subject_name { "Further education" }
      subject_code { "41" }
      type { :FurtherEducationSubject }
    end

    trait :english do
      subject_name { "English" }
      subject_code { "E" }
      type { "SecondarySubject" }
    end

    trait :modern_languages do
      subject_name { "Modern Languages" }
      subject_code { nil }
      type { "SecondarySubject" }
    end

    trait :humanities do
      subject_name { "Humanities" }
      subject_code { nil }
      type { "DiscontinuedSubject" }
    end

    trait :japanese do
      subject_name { "Japanese" }
      subject_code { "19" }
      type { :ModernLanguagesSubject }
    end

    trait :biology do
      subject_name { "Biology" }
      subject_code { "C1" }
      type { :SecondarySubject }
    end

    trait :modern_languages do
      subject_name { "Modern Languages" }
      subject_code { nil }
      type { :SecondarySubject }
    end
  end
end
