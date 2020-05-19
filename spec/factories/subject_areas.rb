FactoryBot.define do
  factory :subject_area do
    trait :primary do
      typename { "PrimarySubject" }
      name { "Primary" }
    end

    trait :secondary do
      typename { "SecondarySubject" }
      name { "Secondary" }
    end

    trait :modern_languages do
      typename { "ModernLanguagesSubject" }
      name { "Modern Language" }
    end

    trait :further_education do
      typename { "FurtherEducationSubject" }
      name { "Further Education" }
    end

    trait :discontinued do
      typename { "DiscontinuedSubject" }
      name { "Discontinued" }
    end
  end
end
