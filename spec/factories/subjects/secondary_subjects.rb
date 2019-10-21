FactoryBot.define do
  subjects = {
      # Modern Lanuages has been removed as it would cause validation errors if it
      # isn't paired with a valid modern language subject use a trait if you want to create it
     "Art and design"                  => "W1",
     "Science"                         => "F0",
     "Biology"                         => "C1",
     "Business studies"                => "08",
     "Chemistry"                       => "F1",
     "Citizenship"                     => "09",
     "Classics"                        => "Q8",
     "Communication and media studies" => "P3",
     "Computing"                       => "11",
     "Dance"                           => "12",
     "Design and technology"           => "DT",
     "Drama"                           => "13",
     "Economics"                       => "L1",
     "English"                         => "Q3",
     "Geography"                       => "F8",
     "Health and social care"          => "L5",
     "History"                         => "V1",
     "Mathematics"                     => "G1",
     "Music"                           => "W3",
     "Philosophy"                      => "P1",
     "Physical education"              => "C6",
     "Physics"                         => "F3",
     "Psychology"                      => "C8",
     "Religious education"             => "V6",
     "Social sciences"                 => "14",
  }

  factory :secondary_subject do
    transient do
      sample_subject { subjects.to_a.sample }
    end

    subject_name { sample_subject.first }
    subject_code { sample_subject.second }

    trait :art_and_design do
      subject_name { "Art and design" }
      subject_code { subjects["Art and design"] }
    end

    trait :science do
      subject_name { "Science" }
      subject_code { subjects["Science"] }
    end

    trait :biology do
      subject_name { "Biology" }
      subject_code { subjects["Biology"] }
    end

    trait :business_studies do
      subject_name { "Business studies" }
      subject_code { subjects["Business studies"] }
    end

    trait :chemistry do
      subject_name { "Chemistry" }
      subject_code { subjects["Chemistry"] }
    end

    trait :citizenship do
      subject_name { "Citizenship" }
      subject_code { subjects["Citizenship"] }
    end

    trait :classics do
      subject_name { "Classics" }
      subject_code { subjects["Classics"] }
    end

    trait :communication_and_media_studies do
      subject_name { "Communication and media studies" }
      subject_code { subjects["Communication and media studies"] }
    end

    trait :computing do
      subject_name { "Computing" }
      subject_code { subjects["Computing"] }
    end

    trait :dance do
      subject_name { "Dance" }
      subject_code { subjects["Dance"] }
    end

    trait :design_and_technology do
      subject_name { "Design and technology" }
      subject_code { subjects["Design and technology"] }
    end

    trait :drama do
      subject_name { "Drama" }
      subject_code { subjects["Drama"] }
    end

    trait :economics do
      subject_name { "Economics" }
      subject_code { subjects["Economics"] }
    end

    trait :english do
      subject_name { "English" }
      subject_code { subjects["English"] }
    end

    trait :geography do
      subject_name { "Geography" }
      subject_code { subjects["Geography"] }
    end

    trait :health_and_social_care do
      subject_name { "Health and social care" }
      subject_code { subjects["Health and social care"] }
    end

    trait :history do
      subject_name { "History" }
      subject_code { subjects["History"] }
    end

    trait :mathematics do
      subject_name { "Mathematics" }
      subject_code { subjects["Mathematics"] }
    end

    trait :music do
      subject_name { "Music" }
      subject_code { subjects["Music"] }
    end

    trait :philosophy do
      subject_name { "Philosophy" }
      subject_code { subjects["Philosophy"] }
    end

    trait :physical_education do
      subject_name { "Physical education" }
      subject_code { subjects["Physical education"] }
    end

    trait :physics do
      subject_name { "Physics" }
      subject_code { subjects["Physics"] }
    end

    trait :psychology do
      subject_name { "Psychology" }
      subject_code { subjects["Psychology"] }
    end

    trait :religious_education do
      subject_name { "Religious education" }
      subject_code { subjects["Religious education"] }
    end

    trait :social_sciences do
      subject_name { "Social sciences" }
      subject_code { subjects["Social sciences"] }
    end

    trait :modern_languages do
      subject_name { "Modern Languages" }
      subject_code { nil }
    end
  end
end
