FactoryBot.define do
  subjects = {
     "French"                                => "15",
     "English as a second or other language" => "16",
     "German"                                => "17",
     "Italian"                               => "18",
     "Japanese"                              => "19",
     "Mandarin"                              => "20",
     "Russian"                               => "21",
     "Spanish"                               => "22",
     "Modern languages (other)"              => "24",
  }

  factory :modern_languages_subject do
    transient do
      sample_subject { subjects.to_a.sample }
    end

    subject_name { sample_subject.first }
    subject_code { sample_subject.second }

    trait :french do
      subject_name { "French" }
      subject_code { subjects["French"] }
    end

    trait :english_as_a_second_lanaguge_or_other_language do
      subject_name { "English as a second or other language" }
      subject_code { subjects["English as a second or other language"] }
    end

    trait :german do
      subject_name { "German" }
      subject_code { subjects["German"] }
    end

    trait :italian do
      subject_name { "Italian" }
      subject_code { subjects["Italian"] }
    end

    trait :japanese do
      subject_name { "Japanese" }
      subject_code { subjects["Japanese"] }
    end

    trait :mandarin do
      subject_name { "Mandarin" }
      subject_code { subjects["Mandarin"] }
    end

    trait :russian do
      subject_name { "Russian" }
      subject_code { subjects["Russian"] }
    end

    trait :spanish do
      subject_name { "Spanish" }
      subject_code { subjects["Spanish"] }
    end

    trait :modern_languages_other do
      subject_name { "Modern languages (other)" }
      subject_code { subjects["Modern languages (other)"] }
    end
  end
end
