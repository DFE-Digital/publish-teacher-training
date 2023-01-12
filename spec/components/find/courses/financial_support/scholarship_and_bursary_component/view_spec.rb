require "rails_helper"

describe Find::Courses::FinancialSupport::ScholarshipAndBursaryComponent::View, type: :component do
  let(:course) {
    build(:course,
      subjects: [
        build(:primary_subject,
          subject_name: "primary with mathematics",
          financial_incentive: FinancialIncentive.new(scholarship: 2000,
            bursary_amount: 3000,
            early_career_payments: 2000)),
      ]).decorate
  }

  context "bursaries_and_scholarships_announced feature flag is on" do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    it "renders scholarship and bursary details" do
      result = render_inline(described_class.new(course))

      expect(result.text).to include("With a scholarship or bursary, you’ll also get early career payments")
    end

    context "early career payments" do
      it "renders additional guidance if a course has early career payments" do
        result = render_inline(described_class.new(course))

        expect(result.text).to include("With a scholarship or bursary, you’ll also get early career payments of £2,000")
      end

      it "does not render additional guidance if a course does not have early career payments" do
        course.subjects.first.financial_incentive.early_career_payments = nil

        result = render_inline(described_class.new(course))

        expect(result.text).not_to include("With a scholarship or bursary, you’ll also get early career payments of £2,000")
      end
    end

    context "when course has a scholarship" do
      shared_examples "subject with scholarship" do |subject_trait, scholarship_body, scholarship_url|
        context "#{subject_trait} subject" do
          let(:course) { build(:course, subjects:).decorate }

          let(:subjects) { [build(:secondary_subject, subject_trait)] }

          it "renders link to scholarship body" do
            render_inline(described_class.new(course))

            expect(page).to have_text("For a scholarship, you’ll need to apply through the #{scholarship_body}")
            expect(page).to have_link("Check whether you’re eligible for a scholarship and find out how to apply", href: scholarship_url)
          end
        end
      end

      include_examples "subject with scholarship", :physics, "Institute of Physics", "https://www.iop.org/about/support-grants/iop-teacher-training-scholarships"
      include_examples "subject with scholarship", :chemistry, "Royal Society of Chemistry", "https://www.rsc.org/prizes-funding/funding/teacher-training-scholarships/"
      include_examples "subject with scholarship", :computing, "Chartered Institute for IT", "https://www.bcs.org/qualifications-and-certifications/training-and-scholarships-for-teachers/bcs-computer-teacher-scholarships/"
      include_examples "subject with scholarship", :mathematics, "Institute of Mathematics and its Applications", "https://teachingmathsscholars.org/eligibilitycriteria"
      include_examples "subject with scholarship", :french, "British Council", "https://www.britishcouncil.org/"
      include_examples "subject with scholarship", :german, "British Council", "https://www.britishcouncil.org/"
      include_examples "subject with scholarship", :spanish, "British Council", "https://www.britishcouncil.org/"
    end

    context "when course has scholarship but we don\"t have a institution to obtain further info from" do
      let(:course) {
        build(:course,
          subjects: [
            build(:secondary_subject, :design_and_technology,
              financial_incentive: FinancialIncentive.new(scholarship: 2000,
                bursary_amount: 3000,
                early_career_payments: 2000)),
          ]).decorate
      }

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
