require "rails_helper"

describe Courses::AssignProgramTypeService do
  let(:service) { described_class.new }
  let(:course) { create(:course) }
  let(:execute_service) { service.execute(funding_type, course) }

  before do
    execute_service
  end

  context "when the funding_type is salary" do
    let(:funding_type) { "salary" }

    context "and the course is not self_accredited" do
      let(:provider) { create(:provider, accrediting_provider: "N") }
      let(:course) { create(:course, :with_accrediting_provider, provider: provider) }

      it "should return :school_direct_salaried_training_programme" do
        expect(course.program_type).to eq("school_direct_salaried_training_programme")
      end
    end

    context "when the course is self accredited" do
      let(:course) { create(:course, :self_accredited) }
      it "an error should be added to the course object" do
        expect(course.errors["program_type"].first).to eq("Salary is not valid for a self accredited course")
      end
    end
  end

  context "when the funding_type is apprenticeship" do
    let(:funding_type) { "apprenticeship" }

    it "should return :pg_teaching_apprenticeship" do
      expect(course.program_type).to eq("pg_teaching_apprenticeship")
    end
  end

  context "when the funding_type is fee" do
    let(:funding_type) { "fee" }
    let(:provider) { build(:provider, provider_type: provider_type) }

    context "and the course is not self accredited" do
      let(:course) { create(:course, :with_accrediting_provider) }

      it "should return :school_direct_training_programme" do
        expect(course.program_type).to eq("school_direct_training_programme")
      end
    end

    context "the course is self accredited" do
      let(:provider) { build(:provider, trait) }

      context "and they are a scitt" do
        let(:trait) { :scitt }
        let(:course) { create(:course, provider: provider) }

        it "should return :scitt_programme" do
          expect(course.program_type).to eq("scitt_programme")
        end
      end

      context "and they are a HEI" do
        let(:trait) { :university }
        let(:course) { create(:course, provider: provider) }

        it "should return :higher_education_programme" do
          expect(course.program_type).to eq("higher_education_programme")
        end
      end
    end

    context "with an empty funding_type paramater" do
      let(:course) { create(:course, :with_scitt) }
      let(:funding_type) { nil }

      it "returns the courses current study mode" do
        expect(course.program_type).to eq("scitt_programme")
      end
    end
  end
end
