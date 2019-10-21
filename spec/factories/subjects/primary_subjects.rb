FactoryBot.define do
  subjects = {
    "Primary"                            => "00",
    "Primary with English"               => "01",
    "Primary with geography and history" => "02",
    "Primary with mathematics"           => "03",
    "Primary with modern languages"      => "04",
    "Primary with physical education"    => "06",
    "Primary with science"               => "07",
  }

  factory :primary_subject do
    transient do
      sample_subject { subjects.to_a.sample }
    end

    subject_name { sample_subject.first }
    subject_code { sample_subject.second }

    trait :primary do
      subject_name { "Primary" }
      subject_code { subjects["Primary"] }
    end

    trait :primary_with_english do
      subject_name { "Primary with English" }
      subject_code { subjects["Primary with English"] }
    end

    trait :primary_with_geography_and_history do
      subject_name { "Primary with geography and history" }
      subject_code { subjects["Primary with geography and history"] }
    end

    trait :primary_with_mathematics do
      subject_name { "Primary with mathematics" }
      subject_code { subjects["Primary with mathematics"] }
    end

    trait :primary_with_modern_languages do
      subject_name { "Primary with modern languages" }
      subject_code { subjects["Primary with modern languages"] }
    end

    trait :primary_with_physical_education do
      subject_name { "Primary with physical education" }
      subject_code { subjects["Primary with physical education"] }
    end

    trait :primary_with_science do
      subject_name { "Primary with science" }
      subject_code { subjects["Primary with science"] }
    end
  end
end
