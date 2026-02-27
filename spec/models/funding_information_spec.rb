# frozen_string_literal: true

require "rails_helper"

describe FundingInformation do
  describe "NON_UK_BURSARY_ELIGIBLE_SUBJECTS" do
    it "contains the expected subjects" do
      expect(described_class::NON_UK_BURSARY_ELIGIBLE_SUBJECTS).to eq(
        [
          "Italian",
          "Japanese",
          "Mandarin",
          "Russian",
          "Modern languages (other)",
          "Ancient Greek",
          "Ancient Hebrew",
        ],
      )
    end

    it "is frozen" do
      expect(described_class::NON_UK_BURSARY_ELIGIBLE_SUBJECTS).to be_frozen
    end
  end

  describe "NON_UK_SCHOLARSHIP_ELIGIBLE_SUBJECTS" do
    it "contains the expected subjects" do
      expect(described_class::NON_UK_SCHOLARSHIP_ELIGIBLE_SUBJECTS).to eq(
        %w[Physics French German Spanish],
      )
    end

    it "is frozen" do
      expect(described_class::NON_UK_SCHOLARSHIP_ELIGIBLE_SUBJECTS).to be_frozen
    end
  end

  describe "SCHOLARSHIP_BODY_SUBJECTS" do
    it "maps subject codes to scholarship body keys" do
      expect(described_class::SCHOLARSHIP_BODY_SUBJECTS).to eq(
        {
          "F1" => "chemistry",
          "11" => "computing",
          "G1" => "mathematics",
          "F3" => "physics",
          "15" => "french",
          "17" => "german",
          "22" => "spanish",
        },
      )
    end

    it "is frozen" do
      expect(described_class::SCHOLARSHIP_BODY_SUBJECTS).to be_frozen
    end
  end

  describe "BURSARY_EXCLUDED_COURSE_PATTERNS" do
    it "contains the expected patterns" do
      expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS).to eq(
        [/^Drama/, /^Media Studies/, /^PE/, /^Physical/],
      )
    end

    it "matches expected course names" do
      expect("Drama with English").to match(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS.first)
      expect("Media Studies with English").to match(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS[1])
      expect("PE with Mathematics").to match(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS[2])
      expect("Physical Education with Mathematics").to match(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS[3])
    end

    it "does not match non-excluded course names" do
      expect("Mathematics with Physics").not_to match(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS.first)
    end

    it "is frozen" do
      expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS).to be_frozen
    end
  end
end
