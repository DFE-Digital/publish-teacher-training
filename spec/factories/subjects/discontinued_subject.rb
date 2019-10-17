FactoryBot.define do
  subjects = [
    { subject_name: "Humanities" },
    { subject_name: "Balanced Science" },
  ]

  factory :discontinued_subject do
    transient do
      sample_subject { subjects.sample }
    end

    subject_name { sample_subject[:subject_name] }
    subject_code { nil }
    type { :DiscontinuedSubject }

    trait :humanities do
      subject_name { "Humanities" }
      subject_code { nil }
      type { "DiscontinuedSubject" }
    end

    trait :balanced_science do
      subject_name { "Balanced Science" }
      subject_code { nil }
      type { "DiscontinuedSubject" }
    end
  end
end
