FactoryBot.define do
  subjects = [
      # Modern Lanuages has been removed as it would cause validation errors if it
      # isn't paired with a valid modern language subject use a trait if you want to create it
      { subject_name: "Art and design", subject_code: "W1" },
      { subject_name: "Science", subject_code:  "F0" },
      { subject_name: "Biology", subject_code:  "C1" },
      { subject_name: "Business studies", subject_code: "08" },
      { subject_name: "Chemistry", subject_code: "F1" },
      { subject_name: "Citizenship", subject_code:  "09" },
      { subject_name: "Classics", subject_code: "Q8" },
      { subject_name: "Communication and media studies", subject_code: "P3" },
      { subject_name: "Computing", subject_code: "11" },
      { subject_name: "Dance", subject_code: "12" },
      { subject_name: "Design and technology", subject_code: "DT" },
      { subject_name: "Drama", subject_code: "13" },
      { subject_name: "Economics", subject_code: "L1" },
      { subject_name: "English", subject_code: "Q3" },
      { subject_name: "Geography", subject_code: "F8" },
      { subject_name: "Health and social care", subject_code: "L5" },
      { subject_name: "History", subject_code:  "V1" },
      { subject_name: "Mathematics", subject_code: "G1" },
      { subject_name: "Music", subject_code: "W3" },
      { subject_name: "Philosophy", subject_code: "P1" },
      { subject_name: "Physical education", subject_code: "C6" },
      { subject_name: "Physics", subject_code: "F3" },
      { subject_name: "Psychology", subject_code: "C8" },
      { subject_name: "Religious education", subject_code: "V6" },
      { subject_name: "Social sciences", subject_code: "14" },
    ]

  factory :secondary_subject do
    transient do
      sample_subject { subjects.sample }
    end

    subject_name { sample_subject[:subject_name] }
    subject_code { sample_subject[:subject_code] }
    type { :SecondarySubject }

    trait :art_and_design do
      subject_name { "Art and design" }
      subject_code { "W1" }
      type { :SecondarySubject }
    end

    trait :science do
      subject_name { "Science" }
      subject_code { "F0" }
      type { :SecondarySubject }
    end

    trait :biology do
      subject_name { "Biology" }
      subject_code { "C1" }
      type { :SecondarySubject }
    end

    trait :business_studies do
      subject_name { "Business studies" }
      subject_code { "08" }
      type { :SecondarySubject }
    end

    trait :chemistry do
      subject_name { "Chemistry" }
      subject_code { "F1" }
      type { :SecondarySubject }
    end

    trait :citizenship do
      subject_name { "Citizenship" }
      subject_code { "09" }
      type { :SecondarySubject }
    end

    trait :classics do
      subject_name { "Classics" }
      subject_code { "Q8" }
      type { :SecondarySubject }
    end

    trait :communication_and_media_studies do
      subject_name { "Communication and media studies" }
      subject_code { "P3" }
      type { :SecondarySubject }
    end

    trait :computing do
      subject_name { "Computing" }
      subject_code { "11" }
      type { :SecondarySubject }
    end

    trait :dance do
      subject_name { "Dance" }
      subject_code { "12" }
      type { :SecondarySubject }
    end

    trait :design_and_technology do
      subject_name { "Design and technology" }
      subject_code { "DT" }
      type { :SecondarySubject }
    end

    trait :drama do
      subject_name { "Drama" }
      subject_code { "13" }
      type { :SecondarySubject }
    end

    trait :economics do
      subject_name { "Economics" }
      subject_code { "L1" }
      type { :SecondarySubject }
    end

    trait :english do
      subject_name { "English" }
      subject_code { "Q3" }
      type { "SecondarySubject" }
    end

    trait :geography do
      subject_name { "Geography" }
      subject_code { "F8" }
      type { "SecondarySubject" }
    end

    trait :health_and_social_care do
      subject_name { "Health and social care" }
      subject_code { "L5" }
      type { "SecondarySubject" }
    end

    trait :history do
      subject_name { "History" }
      subject_code { "V1" }
      type { "SecondarySubject" }
    end

    trait :mathematics do
      subject_name { "Mathematics" }
      subject_code { "G1" }
      type { "SecondarySubject" }
    end

    trait :music do
      subject_name { "Music" }
      subject_code { "W3" }
      type { "SecondarySubject" }
    end

    trait :philosophy do
      subject_name { "Philosophy" }
      subject_code { "P1" }
      type { "SecondarySubject" }
    end

    trait :physical_education do
      subject_name { "Physical education" }
      subject_code { "C6" }
      type { "SecondarySubject" }
    end

    trait :physics do
      subject_name { "Physics" }
      subject_code { "F3" }
      type { "SecondarySubject" }
    end

    trait :psychology do
      subject_name { "Psychology" }
      subject_code { "C8" }
      type { "SecondarySubject" }
    end

    trait :religious_education do
      subject_name { "Religious education" }
      subject_code { "V6" }
      type { "SecondarySubject" }
    end

    trait :social_sciences do
      subject_name { "Social sciences" }
      subject_code { "14" }
      type { "SecondarySubject" }
    end

    trait :modern_languages do
      subject_name { "Modern Languages" }
      subject_code { nil }
      type { :SecondarySubject }
    end
  end
end
