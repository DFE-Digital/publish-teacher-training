# frozen_string_literal: true

FactoryBot.define do
  design_technology_subjects = {
    "Engineering" => "D420",
    "Product design" => "D440",
    "Food technology" => "D470",
    "Textiles" => "D460",
    "Graphics" => "D490",
  }

  factory :design_technology_subject do
    transient do
      sample_subject { design_technology_subjects.to_a.sample }
    end

    subject_name { sample_subject.first }
    subject_code { sample_subject.second }

    trait :engineering do
      subject_name { "Engineering" }
      subject_code { design_technology_subjects["Engineering"] }
    end

    trait :product_design do
      subject_name { "Product design" }
      subject_code { design_technology_subjects["Product design"] }
    end

    trait :food_technology do
      subject_name { "Food technology" }
      subject_code { design_technology_subjects["Food technology"] }
    end

    trait :textiles do
      subject_name { "Textiles" }
      subject_code { design_technology_subjects["Textiles"] }
    end

    trait :graphics do
      subject_name { "Graphics" }
      subject_code { design_technology_subjects["Graphics"] }
    end
  end
end
