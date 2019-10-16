FactoryBot.define do
  subjects = [
     { subject_name: "Primary", subject_code: "00" },
     { subject_name: "Primary with English", subject_code: "01" },
     { subject_name: "Primary with geography and history", subject_code: "02" },
     { subject_name: "Primary with mathematics", subject_code: "03" },
     { subject_name: "Primary with modern languages", subject_code: "04" },
     { subject_name: "Primary with physical education", subject_code: "06" },
     { subject_name: "Primary with science", subject_code: "07" },
   ]

  factory :primary_subject do
    transient do
      sample_subject { subjects.sample }
    end

    subject_name { sample_subject[:subject_name] }
    subject_code { sample_subject[:subject_code] }
    type { :PrimarySubject }

    trait :primary do
      subject_name { "Primary" }
      subject_code { "00" }
      type { "PrimarySubject" }
    end

    trait :primary_with_english do
      subject_name { "Primary with English" }
      subject_code { "01" }
      type { "PrimarySubject" }
    end

    trait :primary_with_geography_and_history do
      subject_name { "Primary with geography and history" }
      subject_code { "02" }
      type { "PrimarySubject" }
    end

    trait :primary_with_mathematics do
      subject_name { "Primary with mathematics" }
      subject_code { "03" }
      type { "PrimarySubject" }
    end

    trait :primary_with_modern_languages do
      subject_name { "Primary with modern languages" }
      subject_code { "04" }
      type { "PrimarySubject" }
    end

    trait :primary_with_physical_education do
      subject_name { "Primary with physical education" }
      subject_code { "06" }
      type { "PrimarySubject" }
    end

    trait :primary_with_science do
      subject_name { "Primary with science" }
      subject_code { "07" }
      type { "PrimarySubject" }
    end
  end
end
