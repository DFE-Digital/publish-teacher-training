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

  describe "#bursary_value" do
    let(:helper_instance_class) do
      Struct.new(:course, :visa_sponsorship, keyword_init: true) do
        include FinancialIncentiveHintHelper
      end
    end

    let(:subject_with_incentives) { create(:secondary_subject, :chemistry, bursary_amount: 20_000, scholarship: 22_000) }

    let(:course) do
      create(
        :course,
        :secondary,
        :open,
        :published,
        provider: build(:provider),
        subjects: [subject_with_incentives],
        master_subject_id: subject_with_incentives.id,
      )
    end

    let(:instance) { helper_instance_class.new(course:, visa_sponsorship:) }
    let(:visa_sponsorship) { nil }

    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    after do
      FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
    end

    it "returns the hint text when the flag is active and the course has incentives" do
      expect(instance.bursary_value).to eq("Scholarships of £22,000 or bursaries of £20,000 are available")
    end

    context "when visa sponsorship filtering is in effect (and the subject is not physics or languages)" do
      let(:visa_sponsorship) { "true" }

      it "hides the hint" do
        expect(instance.bursary_value).to be_nil
      end
    end

    context "when the feature flag is inactive" do
      before do
        FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
      end

      it "hides the hint" do
        expect(instance.bursary_value).to be_nil
      end
    end
  end
end
