# frozen_string_literal: true

require "rails_helper"

describe CourseFunding::View do
  subject(:view) { described_class.new(course_funding) }

  let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:provider) { build(:provider, recruitment_cycle: current_recruitment_cycle) }
  let(:course) { build(:course, provider:) }
  let(:course_funding) { CourseFunding.new(course) }

  describe "delegation" do
    it "delegates logic methods to CourseFunding" do
      %i[has_bursary?
         has_scholarship?
         has_scholarship_and_bursary?
         bursary_only?
         excluded_from_bursary?
         has_early_career_payments?
         max_bursary_amount
         max_scholarship_amount
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

  describe "#bursary_first_line_ending" do
    context "when there is one bursary requirement" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, bursary_amount: "3000")]) }

      it "returns the requirement with a period" do
        expect(view.bursary_first_line_ending).to end_with(".")
      end
    end

    context "when there are multiple bursary requirements" do
      let(:course) do
        build(:course, provider:, subjects: [
          build(:primary_subject, subject_name: "Primary with mathematics",
                                  financial_incentive: FinancialIncentive.new(bursary_amount: 3000)),
        ])
      end

      it "returns a colon" do
        expect(view.bursary_first_line_ending).to eq(":")
      end
    end
  end

  describe "#financial_incentive_details" do
    context "bursaries and scholarships is announced" do
      before do
        FeatureFlag.activate(:bursaries_and_scholarships_announced)
      end

      context "course has no financial incentive" do
        it "returns 'None available'" do
          expect(view.financial_incentive_details).to eq("None available")
        end
      end

      context "course has both bursary and scholarship" do
        let(:financial_incentive) { build_stubbed(:financial_incentive, scholarship: "2000", bursary_amount: "3000") }

        before do
          allow(course).to receive(:financial_incentives).and_return([financial_incentive])
        end

        it "returns scholarship and bursary details" do
          expect(view.financial_incentive_details).to eq("Scholarships of £2,000 and bursaries of £3,000 are available")
        end
      end

      context "course only has bursary" do
        let(:financial_incentive) { build_stubbed(:financial_incentive, bursary_amount: "3000") }

        before do
          allow(course).to receive(:financial_incentives).and_return([financial_incentive])
        end

        it "returns bursary details" do
          expect(view.financial_incentive_details).to eq("Bursaries of £3,000 available")
        end
      end

      context "course is in the next cycle" do
        before do
          allow(course).to receive(:recruitment_cycle_year).and_return(current_recruitment_cycle.year.to_i + 1)
        end

        it "returns 'Information not yet available'" do
          expect(view.financial_incentive_details).to eq("Information not yet available")
        end
      end
    end

    context "bursaries and scholarships is not announced" do
      it "returns 'Information not yet available'" do
        expect(view.financial_incentive_details).to eq("Information not yet available")
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
    context "when course has both bursary and scholarship" do
      let(:course) { build(:course, provider:, subjects: [build(:secondary_subject, bursary_amount: "3000", scholarship: "2000")]) }

      it "returns the hint text using course funding amounts" do
        expect(view.hint_text).to eq("Scholarships of £2,000 or bursaries of £3,000 are available")
      end
    end

    context "when course has no incentives" do
      it "returns nil" do
        expect(view.hint_text).to be_nil
      end
    end
  end

  describe "#bursary_and_scholarship_flag_active_or_preview?" do
    it "returns true when feature flag is active" do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)

      expect(view.bursary_and_scholarship_flag_active_or_preview?).to be true
    end

    it "returns false when feature flag is inactive" do
      expect(view.bursary_and_scholarship_flag_active_or_preview?).to be false
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
