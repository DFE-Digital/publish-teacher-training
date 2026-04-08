# frozen_string_literal: true

require "rails_helper"

describe CourseIncentive::View do
  subject(:view) { described_class.new(course_incentive) }

  before { FeatureFlag.activate(:bursaries_and_scholarships_announced) }

  let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:provider) { build(:provider, recruitment_cycle: current_recruitment_cycle) }
  let(:course) { build(:course, provider:) }
  let(:course_incentive) { CourseIncentive.new(course) }

  describe "delegation" do
    it "delegates logic methods to CourseIncentive" do
      %i[has_bursary?
         has_scholarship?
         has_scholarship_and_bursary?
         bursary_only?
         has_early_career_payments?
         bursary_amount
         scholarship_amount
         bursary_eligible_subjects?
         scholarship_eligible_subjects?
         non_uk_funding_available?
         subject_with_scholarship].each do |method|
        expect(view).to respond_to(method)
      end
    end
  end

  describe "#bursary_requirements" do
    context "when course has no bursary" do
      it "returns an empty array" do
        expect(view.bursary_requirements).to eq([])
      end
    end

    context "when course has a bursary" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, bursary_amount: "3000")]) }

      it "returns requirements including second degree" do
        expect(view.bursary_requirements).to include(I18n.t("course.values.bursary_requirements.second_degree"))
      end
    end

    context "when course has Primary with mathematics subject" do
      let(:course) do
        build(:course, provider:, subjects: [
          build(:primary_subject, subject_name: "Primary with mathematics",
                                  financial_incentive: FinancialIncentive.new(bursary_amount: 3000)),
        ])
      end

      it "includes the mathematics requirement" do
        expect(view.bursary_requirements).to include(I18n.t("course.values.bursary_requirements.maths"))
      end
    end
  end

  describe ".hint_text" do
    it "returns combined scholarship and bursary hint" do
      expect(
        described_class.hint_text(bursary_amount: 20_000, scholarship_amount: 22_000),
      ).to eq("Scholarships of £22,000 or bursaries of £20,000 are available")
    end

    it "returns bursary-only hint" do
      expect(
        described_class.hint_text(bursary_amount: 20_000, scholarship_amount: nil),
      ).to eq("Bursaries of £20,000 are available")
    end

    it "returns scholarship-only hint" do
      expect(
        described_class.hint_text(bursary_amount: nil, scholarship_amount: 22_000),
      ).to eq("Scholarships of £22,000 are available")
    end

    it "returns nil when both are blank" do
      expect(described_class.hint_text(bursary_amount: nil, scholarship_amount: nil)).to be_nil
    end
  end

  describe "#hint_text" do
    context "when course has both bursary and scholarship but no non-UK funding" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, bursary_amount: "3000", scholarship: "2000")]) }

      it "appends 'for UK citizens'" do
        expect(view.hint_text).to eq("Scholarships of £2,000 or bursaries of £3,000 are available for UK citizens")
      end
    end

    context "when course has non-UK funding available" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, bursary_amount: "3000", scholarship: "2000", non_uk_bursary_eligible: true)]) }

      it "does not append 'for UK citizens'" do
        expect(view.hint_text).to eq("Scholarships of £2,000 or bursaries of £3,000 are available")
      end
    end

    context "when course has no incentives" do
      it "returns nil" do
        expect(view.hint_text).to be_nil
      end
    end
  end

  describe "#scholarship_body" do
    context "when course has a subject with a scholarship" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, :physics, scholarship: "31000")]) }

      it "returns the scholarship body text" do
        expect(view.scholarship_body).to eq(I18n.t("find.scholarships.physics.body"))
      end
    end

    context "when course has no subject with a scholarship" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, :history)]) }

      it "returns nil" do
        expect(view.scholarship_body).to be_nil
      end
    end
  end

  describe "#scholarship_url" do
    context "when course has a subject with a scholarship" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, :physics, scholarship: "31000")]) }

      it "returns the scholarship URL" do
        expect(view.scholarship_url).to eq(I18n.t("find.scholarships.physics.url"))
      end
    end

    context "when course has no subject with a scholarship" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, :history)]) }

      it "returns nil" do
        expect(view.scholarship_url).to be_nil
      end
    end
  end
end
