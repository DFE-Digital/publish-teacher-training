FactoryBot.define do
  subjects = [
    { subject_name: "French", subject_code: "15" },
    { subject_name: "English as a second or other language", subject_code: "16" },
    { subject_name: "German", subject_code: "17" },
    { subject_name: "Italian", subject_code: "18" },
    { subject_name: "Japanese", subject_code:  "19" },
    { subject_name: "Mandarin", subject_code:  "20" },
    { subject_name: "Russian", subject_code:  "21" },
    { subject_name: "Spanish", subject_code:  "22" },
    { subject_name: "Modern languages (other)", subject_code: "24" },
   ]

  factory :modern_languages_subject do
    transient do
      sample_subject { subjects.sample }
    end

    subject_name { sample_subject[:subject_name] }
    subject_code { sample_subject[:subject_code] }
    type { :ModernLanguagesSubject }

    trait :french do
      subject_name { "French" }
      subject_code { "15" }
      type { "ModernLanguagesSubject" }
    end

    trait :english_as_a_second_lanaguge_or_other_language do
      subject_name { "English as a second or other language" }
      subject_code { "16" }
      type { "ModernLanguagesSubject" }
    end

    trait :german do
      subject_name { "German" }
      subject_code { "17" }
      type { "ModernLanguagesSubject" }
    end

    trait :italian do
      subject_name { "Italian" }
      subject_code { "18" }
      type { "ModernLanguagesSubject" }
    end

    trait :japanese do
      subject_name { "Japanese" }
      subject_code { "19" }
      type { "ModernLanguagesSubject" }
    end

    trait :mandarin do
      subject_name { "Mandarin" }
      subject_code { "20" }
      type { "ModernLanguagesSubject" }
    end

    trait :russian do
      subject_name { "Russian" }
      subject_code { "21" }
      type { "ModernLanguagesSubject" }
    end

    trait :spanish do
      subject_name { "Spanish" }
      subject_code { "22" }
      type { "ModernLanguagesSubject" }
    end

    trait :modern_languages_other do
      subject_name { "Modern languages (other)" }
      subject_code { "24" }
      type { "ModernLanguagesSubject" }
    end
  end
end
