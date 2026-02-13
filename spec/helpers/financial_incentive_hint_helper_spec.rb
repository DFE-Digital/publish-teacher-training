# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinancialIncentiveHintHelper do
  describe ".hint_text" do
    it "returns the combined scholarship/bursary hint" do
      expect(
        described_class.hint_text(bursary_amount: 20_000, scholarship_amount: 22_000),
      ).to eq("Scholarships of £22,000 or bursaries of £20,000 are available")
    end

    it "returns the bursary-only hint" do
      expect(
        described_class.hint_text(bursary_amount: 20_000, scholarship_amount: nil),
      ).to eq("Bursaries of £20,000 are available")
    end

    it "returns the scholarship-only hint" do
      expect(
        described_class.hint_text(bursary_amount: nil, scholarship_amount: 22_000),
      ).to eq("Scholarships of £22,000 are available")
    end

    it "returns nil when there is no bursary and no scholarship" do
      expect(described_class.hint_text(bursary_amount: nil, scholarship_amount: nil)).to be_nil
    end
  end
end
