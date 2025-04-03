# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View, type: :component do
  let(:course) do
    build(:course,
          subjects: [
            build(:primary_subject,
                  subject_name: "primary with mathematics",
                  financial_incentive: FinancialIncentive.new(scholarship: 2000,
                                                              bursary_amount: 3000,
                                                              early_career_payments: 2000)),
          ]).decorate
  end

  context "bursaries_and_scholarships_announced feature flag is on" do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    it "renders scholarship and bursary details" do
      result = render_inline(described_class.new(course))

      expect(result.text).to include("Bursaries of £3,000 and scholarships of £2,000 are available to eligible trainees.")
    end

    context 'when course has scholarship but we don"t have a institution to obtain further info from' do
      let(:course) do
        build(:course,
              subjects: [
                build(:secondary_subject, :design_and_technology,
                      financial_incentive: FinancialIncentive.new(scholarship: 2000,
                                                                  bursary_amount: 3000,
                                                                  early_career_payments: 2000)),
              ]).decorate
      end

      it "does not try to render link to scholarship body" do
        result = render_inline(described_class.new(course))

        expect(result.text).not_to include("For a scholarship, you’ll need to apply through")
      end
    end
  end

  context "bursaries_and_scholarships_announced feature flag is off" do
    it "does not render scholarship and bursary details" do
      result = render_inline(described_class.new(course))

      expect(result.text).not_to include("With a scholarship or bursary, you’ll also get early career payments")
    end
  end
end
