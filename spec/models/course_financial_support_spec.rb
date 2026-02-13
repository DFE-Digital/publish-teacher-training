# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseFinancialSupport do
  subject(:financial_support) { described_class.new(course) }

  let(:provider) { build(:provider) }

  describe "#financial_incentive" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, scholarship: 1415, early_career_payments: 32) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns the main subject's financial incentive" do
      expect(financial_support.financial_incentive).to eq(incentive)
    end

    context "with Modern Languages as first subject" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [modern_languages], master_subject_id: modern_languages.id) }

      it "returns nil because Modern Languages has no financial incentive" do
        expect(financial_support.financial_incentive).to be_nil
      end
    end
  end

  describe "#bursary_amount and #scholarship_amount" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, scholarship: 1415) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns amounts from the main subject" do
      expect(financial_support.bursary_amount).to eq("255")
      expect(financial_support.scholarship_amount).to eq("1415")
    end

    context "with multiple subjects" do
      let(:religious_education) { find_or_create(:secondary_subject, :religious_education) }
      let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [religious_education, english], master_subject_id: religious_education.id) }

      it "reads from the main subject only" do
        expect(financial_support.bursary_amount).to be_nil
        expect(financial_support.scholarship_amount).to be_nil
      end
    end
  end

  describe "#max_bursary_amount and #max_scholarship_amount" do
    let(:mathematics) { build(:secondary_subject, bursary_amount: "2000", scholarship: "2000") }
    let(:english) { build(:secondary_subject, bursary_amount: "4000", scholarship: "4000") }
    let(:course) { build(:course, :secondary, subjects: [mathematics, english]) }

    it "returns the maximum across all subjects" do
      expect(financial_support.max_bursary_amount).to eq("4000")
      expect(financial_support.max_scholarship_amount).to eq("4000")
    end
  end

  describe "#bursary? and #scholarship?" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, scholarship: 1415) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns true when amounts are present" do
      expect(financial_support.bursary?).to be true
      expect(financial_support.scholarship?).to be true
    end
  end

  describe "#scholarship_and_bursary?" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, scholarship: 1415) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns true when both are present" do
      expect(financial_support.scholarship_and_bursary?).to be true
    end
  end

  describe "#bursary_only?" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, scholarship: nil) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns true when only bursary is present" do
      expect(financial_support.bursary_only?).to be true
    end
  end

  describe "#early_career_payments?" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255, early_career_payments: 32) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns true when early career payments exist" do
      expect(financial_support.early_career_payments?).to be true
    end
  end

  describe "#excluded_from_bursary?" do
    let(:english) { build_stubbed(:secondary_subject, bursary_amount: "30000") }
    let(:drama) { build_stubbed(:secondary_subject, subject_name: "Drama") }
    let(:subjects) { [english, drama] }

    before do
      allow(course).to receive(:subjects).and_return(subjects)
    end

    context "Drama with English" do
      let(:course) { build_stubbed(:course, name: "Drama with English") }

      it "returns true" do
        expect(financial_support.excluded_from_bursary?).to be true
      end
    end

    context "English with Drama" do
      let(:course) { build_stubbed(:course, name: "English with Drama") }

      it "returns false" do
        expect(financial_support.excluded_from_bursary?).to be false
      end
    end

    context "PE with English" do
      let(:pe) { build_stubbed(:secondary_subject, subject_name: "PE") }
      let(:subjects) { [english, pe] }
      let(:course) { build_stubbed(:course, name: "PE with English") }

      it "returns true" do
        expect(financial_support.excluded_from_bursary?).to be true
      end
    end

    context "Physical Education with English" do
      let(:pe) { build_stubbed(:secondary_subject, subject_name: "Physical Education") }
      let(:subjects) { [english, pe] }
      let(:course) { build_stubbed(:course, name: "Physical Education with English") }

      it "returns true" do
        expect(financial_support.excluded_from_bursary?).to be true
      end
    end

    context "Media Studies with English" do
      let(:media) { build_stubbed(:secondary_subject, subject_name: "Media Studies") }
      let(:subjects) { [english, media] }
      let(:course) { build_stubbed(:course, name: "Media Studies with English") }

      it "returns true" do
        expect(financial_support.excluded_from_bursary?).to be true
      end
    end

    context "single subject course" do
      let(:subjects) { [drama] }
      let(:course) { build_stubbed(:course, name: "Drama") }

      it "returns false" do
        expect(financial_support.excluded_from_bursary?).to be false
      end
    end

    context "course with 'and' not 'with'" do
      let(:course) { build_stubbed(:course, name: "Drama and English") }

      it "returns false" do
        expect(financial_support.excluded_from_bursary?).to be false
      end
    end
  end

  describe "#announced?" do
    it "returns the feature flag state" do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
      expect(financial_support.announced?).to be true
      FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
      expect(financial_support.announced?).to be false
    end

    let(:course) { build_stubbed(:course) }
  end

  describe "#non_uk_bursary_eligible?" do
    let(:japanese) { build_stubbed(:secondary_subject, subject_name: "Japanese") }
    let(:course) { build_stubbed(:course, subjects: [japanese]) }

    it "returns true for eligible subjects" do
      expect(financial_support.non_uk_bursary_eligible?).to be true
    end

    let(:english) { build_stubbed(:secondary_subject, subject_name: "English") }

    context "non-eligible subject" do
      let(:course) { build_stubbed(:course, subjects: [english]) }

      it "returns false" do
        expect(financial_support.non_uk_bursary_eligible?).to be false
      end
    end
  end

  describe "#non_uk_scholarship_and_bursary_eligible?" do
    let(:physics) { build_stubbed(:secondary_subject, subject_name: "Physics") }
    let(:course) { build_stubbed(:course, subjects: [physics]) }

    it "returns true for eligible subjects" do
      expect(financial_support.non_uk_scholarship_and_bursary_eligible?).to be true
    end
  end

  describe "#scholarship_body_key" do
    let(:chemistry) { build_stubbed(:secondary_subject, subject_code: "F1") }
    let(:course) { build_stubbed(:course, subjects: [chemistry]) }

    it "returns the scholarship body key" do
      expect(financial_support.scholarship_body_key).to eq("chemistry")
    end
  end

  describe "#bursary_requirements" do
    context "when there is no bursary" do
      let(:course) do
        create(
          :course,
          level: "primary",
          name: "Primary with english",
          course_code: "AAAA",
          subjects: [find_or_create(:primary_subject, :primary_with_english)],
        )
      end

      it "returns no requirements" do
        expect(financial_support.bursary_requirements).to be_empty
      end
    end

    context "when there is a bursary" do
      let(:course) do
        create(
          :course,
          level: "secondary",
          name: "Classics",
          course_code: "AAAA",
          subjects: [find_or_create(:secondary_subject, :classics)],
        )
      end

      it "returns default requirements" do
        expect(financial_support.bursary_requirements).to eql(["a degree of 2:2 or above in any subject"])
      end
    end

    context "when subject is primary with mathematics" do
      let(:primary_maths) { find_or_create(:primary_subject, :primary_with_mathematics) }
      let!(:incentive) { create(:financial_incentive, subject: primary_maths, bursary_amount: 6000) }
      let(:course) do
        create(
          :course,
          level: "primary",
          name: "Primary with mathematics",
          course_code: "BBBB",
          subjects: [primary_maths],
          master_subject_id: primary_maths.id,
        )
      end

      it "includes the maths requirement" do
        expect(financial_support.bursary_requirements).to include("at least grade B in maths A-level (or an equivalent)")
      end
    end
  end

  describe "#bursary_first_line_ending" do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let!(:incentive) { create(:financial_incentive, subject: english, bursary_amount: 255) }
    let(:course) { create(:course, :skip_validate, level: "secondary", subjects: [english], master_subject_id: english.id) }

    it "returns period-terminated requirement for single requirement" do
      expect(financial_support.bursary_first_line_ending).to eq("a degree of 2:2 or above in any subject.")
    end
  end

  describe "#hint_text" do
    let(:subject_with_incentives) { create(:secondary_subject, :chemistry, bursary_amount: 20_000, scholarship: 22_000) }
    let(:subject_without_incentives) { create(:secondary_subject, :history) }
    let(:course) do
      create(
        :course,
        :secondary,
        :open,
        :published,
        provider:,
        subjects: [subject_with_incentives],
        master_subject_id: subject_with_incentives.id,
      )
    end

    before { FeatureFlag.activate(:bursaries_and_scholarships_announced) }
    after { FeatureFlag.deactivate(:bursaries_and_scholarships_announced) }

    it "returns the hint text when flag is active and course has incentives" do
      expect(financial_support.hint_text).to eq("Scholarships of £22,000 or bursaries of £20,000 are available")
    end

    context "when the course is salaried" do
      let(:course) do
        create(:course, :secondary, :open, :published, :salary, provider:,
               subjects: [subject_with_incentives], master_subject_id: subject_with_incentives.id)
      end

      it "returns nil" do
        expect(financial_support.hint_text).to be_nil
      end
    end

    context "when the course is an apprenticeship" do
      let(:course) do
        create(:course, :secondary, :open, :published, :apprenticeship, provider:,
               subjects: [subject_with_incentives], master_subject_id: subject_with_incentives.id)
      end

      it "returns nil" do
        expect(financial_support.hint_text).to be_nil
      end
    end

    context "when the feature flag is inactive" do
      before { FeatureFlag.deactivate(:bursaries_and_scholarships_announced) }

      it "returns nil" do
        expect(financial_support.hint_text).to be_nil
      end
    end

    context "when the course has no financial incentive" do
      let(:course) do
        create(:course, :secondary, :open, :published, provider:,
               subjects: [subject_without_incentives], master_subject_id: subject_without_incentives.id)
      end

      it "returns nil" do
        expect(financial_support.hint_text).to be_nil
      end
    end

    context "when visa sponsorship is active" do
      it "hides the hint for a non-physics, non-language subject" do
        expect(financial_support.hint_text(visa_sponsorship: "true")).to be_nil
      end

      context "with a physics subject" do
        let(:physics_subject) { create(:secondary_subject, :physics, bursary_amount: 26_000, scholarship: 28_000) }
        let(:course) do
          create(:course, :secondary, :open, :published, provider:,
                 subjects: [physics_subject], master_subject_id: physics_subject.id)
        end

        it "shows the hint" do
          expect(financial_support.hint_text(visa_sponsorship: "true")).to be_present
        end
      end

      context "with a language subject" do
        let(:french_subject) { create(:secondary_subject, :french, bursary_amount: 10_000) }
        let(:course) do
          create(:course, :secondary, :open, :published, provider:,
                 subjects: [french_subject], master_subject_id: french_subject.id)
        end

        it "shows the hint" do
          expect(financial_support.hint_text(visa_sponsorship: "true")).to be_present
        end
      end
    end
  end
end
