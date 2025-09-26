# frozen_string_literal: true

require "rails_helper"

describe SubjectsCache do
  let(:cache) { described_class.new }

  describe "#primary_subjects" do
    it "returns primary subjects ordered by name" do
      expect(cache.primary_subjects.map(&:subject_name)).to eq(
        [
          "Primary",
          "Primary with English",
          "Primary with geography and history",
          "Primary with mathematics",
          "Primary with modern languages",
          "Primary with physical education",
          "Primary with science",
        ],
      )
    end
  end

  describe "#primary_subject_codes" do
    it "returns subject codes for primary subjects" do
      expect(cache.primary_subject_codes).to match_array(
        %w[
          00 01 02 03 04 06 07
        ],
      )
    end
  end

  describe "#secondary_subjects" do
    it "returns secondary subjects excluding Modern Languages" do
      expect(cache.secondary_subjects.map(&:subject_name)).to contain_exactly(
        "Ancient Greek",
        "Ancient Hebrew",
        "Art and design",
        "Biology",
        "Business studies",
        "Chemistry",
        "Citizenship",
        "Classics",
        "Communication and media studies",
        "Computing",
        "Dance",
        "Design and technology",
        "Drama",
        "Economics",
        "English",
        "French",
        "Geography",
        "German",
        "Health and social care",
        "History",
        "Italian",
        "Japanese",
        "Latin",
        "Mandarin",
        "Mathematics",
        "Modern languages (other)",
        "Music",
        "Philosophy",
        "Physical education",
        "Physical education with an EBacc subject",
        "Physics",
        "Psychology",
        "Religious education",
        "Russian",
        "Science",
        "Social sciences",
        "Spanish",
      )
    end
  end

  describe "#secondary_subject_codes" do
    it "returns subject codes for secondary subjects" do
      expect(cache.secondary_subject_codes).to match_array(
        %w[
          A1
          A2
          W1
          C1
          08
          F1
          09
          Q8
          P3
          11
          12
          DT
          13
          L1
          Q3
          15
          F8
          17
          L5
          V1
          18
          19
          A0
          20
          G1
          24
          W3
          P1
          C6
          C7
          F3
          C8
          V6
          21
          F0
          14
          22
        ],
      )
    end
  end

  describe "#all_subjects" do
    it "returns all active subjects excluding Modern Languages" do
      create(:secondary_subject, subject_name: "Biology", subject_code: "C1")
      create(:secondary_subject, subject_name: "Chemistry", subject_code: "F1")
      create(:secondary_subject, subject_name: "Modern Languages", subject_code: nil)
      create(:secondary_subject, subject_name: "Physics", subject_code: "F3")
      create(:secondary_subject, subject_name: "History", subject_code: "V1")

      subjects = cache.all_subjects

      expect(subjects.map(&:name)).to contain_exactly("Primary", "Primary with English", "Primary with geography and history", "Primary with mathematics", "Primary with modern languages", "Primary with physical education", "Primary with science", "Art and design", "Science", "Biology", "Business studies", "Chemistry", "Citizenship", "Classics", "Communication and media studies", "Computing", "Dance", "Design and technology", "Drama", "Economics", "English", "Geography", "Health and social care", "History", "Mathematics", "Music", "Philosophy", "Physical education", "Physics", "Psychology", "Religious education", "Social sciences", "Latin", "Ancient Greek", "Ancient Hebrew", "Physical education with an EBacc subject", "French", "German", "Italian", "Japanese", "Mandarin", "Russian", "Spanish", "Modern languages (other)", "Further education", "Biology", "Chemistry", "Physics", "History", "Electronics", "Engineering", "Food technology", "Product design", "Textiles")
      expect(subjects.map(&:value)).to match_array(
        %w[
          00
          01
          02
          03
          04
          06
          07
          W1
          F0
          C1
          08
          F1
          09
          Q8
          P3
          11
          12
          DT
          13
          L1
          Q3
          F8
          L5
          V1
          G1
          W3
          P1
          C6
          F3
          C8
          V6
          14
          A0
          A1
          A2
          C7
          15
          17
          18
          19
          20
          21
          22
          24
          41
          C1
          F1
          F3
          V1
          DTE
          DTEN
          DTF
          DTP
          DTT
        ],
      )
    end
  end

  describe "#expire cache" do
    it "deletes the relevant cache keys" do
      expect(Rails.cache).to receive(:delete).with("subjects:primary")
      expect(Rails.cache).to receive(:delete).with("subjects:secondary")
      expect(Rails.cache).to receive(:delete).with("subjects:all")

      cache.expire_cache
    end
  end
end
