# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::FinancialSupport::BursaryComponent::View, type: :component do
  let(:course) { create(:course, subjects: [create(:primary_subject, subject_name: "primary with mathematics", financial_incentive: FinancialIncentive.new(bursary_amount: 3000))]) }
  let(:incentive_view) { CourseIncentive::View.new(CourseIncentive.new(course)) }

  context "bursaries_and_scholarships_announced feature flag is on" do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
      render_inline(described_class.new(incentive_view))
    end

    it "renders bursary details" do
      expect(page).to have_link("Find out more about bursaries.", href: /url=#{CGI.escape('https://getintoteaching.education.gov.uk/funding-and-support/bursaries')}&/)
      expect(page.has_text?("Bursaries of £3,000 are available to eligible trainees.")).to be true
      expect(page.has_text?("will depend on your degree")).to be false
    end

    context "when the bursary depends on the degree" do
      let(:course) { create(:course, :secondary, subjects: [create(:secondary_subject, bursary_amount: "20000", degree_dependent: true)]) }

      it "renders the maximum amount and that it depends on the degree" do
        expect(page.has_text?("Bursaries of up to £20,000 are available to eligible trainees.")).to be true
        expect(page.has_text?("The amount you are eligible for will depend on your degree.")).to be true
      end
    end
  end

  context "bursaries_and_scholarships_announced feature flag is off" do
    it "does not render bursary details" do
      render_inline(described_class.new(incentive_view))

      expect(page.has_text?("You could be eligible for a bursary of £3,000")).to be false
    end
  end
end
