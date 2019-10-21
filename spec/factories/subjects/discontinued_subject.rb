FactoryBot.define do
  subjects = {
    "Humanities"       => nil,
    "Balanced Science" => nil,
  }

  factory :discontinued_subject do
    transient do
      sample_subject { subjects.to_a.sample }
    end

    subject_name { sample_subject.first }
    subject_code { sample_subject.second }

    trait :humanities do
      subject_name { "Humanities" }
      subject_code { subjects["Humanities"] }
    end

    trait :balanced_science do
      subject_name { "Balanced Science" }
      subject_code { subjects["Balanced Science"] }
    end
  end
end
