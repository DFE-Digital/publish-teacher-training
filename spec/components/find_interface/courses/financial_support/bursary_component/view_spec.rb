require "rails_helper"

describe FindInterface::Courses::FinancialSupport::BursaryComponent::View, type: :component do
  let(:course) { create(:course, subjects: [create(:primary_subject, subject_name: "primary with mathematics", financial_incentive: FinancialIncentive.new(bursary_amount: 3000))]).decorate }

  context "bursaries_and_scholarships_announced feature flag is on" do
    before do
      allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(true)
      render_inline(described_class.new(course))
    end

    it "renders bursary details" do
      expect(page.has_text?("You could be eligible for a bursary of £3,000")).to be true
    end

    context "bursary requirements" do
      it "renders bursary requirements" do
        expect(page.has_text?("To be eligible for a bursary you’ll need a 2:2 degree in any subject")).to be true
      end
    end
  end

  context "bursaries_and_scholarships_announced feature flag is off" do
    it "does not render bursary details" do
      allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(false)

      render_inline(described_class.new(course))

      expect(page.has_text?("You could be eligible for a bursary of £3,000")).to be false
    end
  end
end
