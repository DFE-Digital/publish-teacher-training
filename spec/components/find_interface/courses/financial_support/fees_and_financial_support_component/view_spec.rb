require "rails_helper"

describe FindInterface::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View, type: :component do
  context "Salaried courses" do
    it "renders salaried course section if the course has a salary" do
      course = build(:course, funding_type: "salary").decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("Financial support is not available for this course because it comes with a salary.")
    end

    it "does not render salaried course section if the course does not have a salary" do
      course = build(:course, funding_type: "fee", subjects: [build(:secondary_subject, bursary_amount: "3000")]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include("Financial support is not available for this course because it comes with a salary.")
    end
  end

  context "Courses excluded from bursary" do
    it "renders the student loans section if the course is excluded from bursary" do
      course = build(:course, funding_type: "fee", name: "Drama", subjects: [build(:secondary_subject), build(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("You may be eligible for a student loan")
      expect(result.text).not_to include("You do not have to apply for a bursary")
    end
  end

  context "Courses with bursary" do
    it "renders the bursary section if the course has a bursary" do
      allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(true)

      course = build(:course, funding_type: "fee", name: "History", subjects: [build(:secondary_subject, bursary_amount: "2000"), build(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("You do not need to apply for a bursary")
    end
  end

  context "Courses with scholarship and bursary" do
    it "renders the scholarships and bursary section" do
      allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(true)

      course = build(:course, funding_type: "fee", name: "History", subjects: [build(:secondary_subject, bursary_amount: "2000", financial_incentive: FinancialIncentive.new(scholarship: "1000")), build(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("To be eligible for a bursary you’ll need a 2:2 degree in any subject")
    end
  end

  context "Courses with student loans" do
    it "renders the student loans section if the course is not salaried, does not have a bursary or scholarship and does not meet bursary exclusion criteria" do
      course = create(:course, funding_type: "fee", name: "Drama", subjects: [create(:primary_subject), create(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("You may be eligible for a student loan")
    end
  end

  context "Fee paying courses" do
    it "renders the fees section" do
      course = create(:course, name: "Music", enrichments: [create(:course_enrichment, fee_uk_eu: "5000", fee_details: "Some fee details")], funding_type: "fee").decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("Some fee details")
    end
  end
end
