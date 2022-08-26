require "rails_helper"

describe FindInterface::Courses::FinancialSupport::BursaryComponent::View, type: :component do
  let(:course) { create(:course, subjects: [create(:primary_subject, subject_name: "primary with mathematics", financial_incentive: FinancialIncentive.new(bursary_amount: 3000))]).decorate }

  context "bursaries_and_scholarships_announced feature flag is on" do
    before do
      allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(true)
      render_inline(described_class.new(course))
    end

    it "renders bursary details" do
      expect(rendered_component).to include("You could be eligible for a bursary of £3,000")
    end

    context "bursary requirements" do
      it "renders bursary requirements" do
        expect(rendered_component).to include("To be eligible for a bursary you’ll need a 2:2 degree in any subject")
      end
    end
  end

  context "bursaries_and_scholarships_announced feature flag is off" do
    it "does not render bursary details" do
      allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(false)

      render_inline(described_class.new(course))

      expect(rendered_component).not_to include("You could be eligible for a bursary of £3,000")
    end
  end
end
