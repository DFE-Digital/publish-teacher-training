# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::FilterKeyDigest do
  describe ".digest" do
    it "returns a SHA256 hex digest" do
      result = described_class.digest(subjects: %w[C1], search_attributes: { "level" => "secondary" })

      expect(result).to match(/\A[a-f0-9]{64}\z/)
    end

    it "is deterministic for the same inputs" do
      args = { subjects: %w[C1 F1], search_attributes: { "level" => "secondary" } }
      first = described_class.digest(**args)
      second = described_class.digest(**args)

      expect(first).to eq(second)
    end

    it "produces the same digest regardless of subject order" do
      attrs = { "level" => "secondary" }

      expect(described_class.digest(subjects: %w[C1 F1], search_attributes: attrs))
        .to eq(described_class.digest(subjects: %w[F1 C1], search_attributes: attrs))
    end

    it "produces different digests for different subjects" do
      attrs = { "level" => "secondary" }

      expect(described_class.digest(subjects: %w[C1], search_attributes: attrs))
        .not_to eq(described_class.digest(subjects: %w[F1], search_attributes: attrs))
    end

    it "produces different digests for different search_attributes" do
      expect(described_class.digest(subjects: %w[C1], search_attributes: { "level" => "secondary" }))
        .not_to eq(described_class.digest(subjects: %w[C1], search_attributes: { "level" => "primary" }))
    end

    it "ignores display-only keys" do
      expect(described_class.digest(subjects: %w[C1], search_attributes: { "level" => "secondary" }))
        .to eq(described_class.digest(subjects: %w[C1], search_attributes: { "level" => "secondary", "location" => "London" }))
    end

    it "handles nil search_attributes" do
      expect(described_class.digest(subjects: %w[C1], search_attributes: nil)).to be_present
    end

    it "normalizes boolean-like values to strings" do
      expect(described_class.digest(subjects: %w[C1], search_attributes: { "can_sponsor_visa" => true }))
        .to eq(described_class.digest(subjects: %w[C1], search_attributes: { "can_sponsor_visa" => "true" }))
    end
  end

  describe ".normalize" do
    it "only keeps FILTER_KEYS" do
      result = described_class.normalize("level" => "secondary", "location" => "London", "funding" => "salary")

      expect(result.keys).to contain_exactly("level", "funding")
    end

    it "converts all values to strings" do
      result = described_class.normalize("can_sponsor_visa" => true)

      expect(result["can_sponsor_visa"]).to eq("true")
    end

    it "converts array elements to strings" do
      result = described_class.normalize("qualifications" => %i[qts pgce])

      expect(result["qualifications"]).to eq(%w[qts pgce])
    end

    it "handles nil" do
      expect(described_class.normalize(nil)).to eq({})
    end
  end
end
