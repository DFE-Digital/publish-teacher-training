# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::FinancialSupport::BursaryComponent::View, type: :component do
  let(:course) { create(:course, subjects: [create(:primary_subject, subject_name: "primary with mathematics", financial_incentive: FinancialIncentive.new(bursary_amount: 3000))]).decorate }

  context "bursaries_and_scholarships_announced feature flag is on" do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
      render_inline(described_class.new(course))
    end

    it "renders bursary details" do
      expect(page.has_text?("Find out whether you are eligible for a bursary")).to be true
      expect(page.has_text?("Bursaries of £3,000 are available to eligible trainees.")).to be true
    end
  end

  context "bursaries_and_scholarships_announced feature flag is off" do
    it "does not render bursary details" do
      render_inline(described_class.new(course))

      expect(page.has_text?("You could be eligible for a bursary of £3,000")).to be false
    end
  end
end
