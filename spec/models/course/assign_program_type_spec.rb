RSpec.describe Course, type: :model do
  describe "#funding_type=" do
    before do
      subject.funding_type = funding_type
    end

    describe "when funding type is salary" do
      let(:funding_type) { "salary" }

      context "an externally accredited courses" do
        let(:subject) { create(:course, :with_accrediting_provider) }

        its(:program_type) { should eq("school_direct_salaried_training_programme") }
      end

      context "a self accredited course" do
        let(:subject) { create(:course) }

        it "should add an error to the course object" do
          expect(subject.errors.count).to eq 1
          expect(subject.errors.messages[:program_type].first).to eq "Salary is not valid for a self accredited course"
        end
      end
    end

    describe "when funding type is apprenticeship" do
      let(:subject) { create(:course, :with_scitt) }
      let(:funding_type) { "apprenticeship" }
      its(:program_type) { should eq("pg_teaching_apprenticeship") }
    end

    describe "when funding type is fee" do
      let(:funding_type) { "fee" }

      context "an externally accredited course" do
        let(:subject) { create(:course, :with_accrediting_provider) }
        its(:program_type) { should eq("school_direct_training_programme") }
      end

      context "a SCITTs self accredited courses" do
        let(:provider) { build(:provider, provider_type: :scitt) }
        let(:subject) { create(:course, provider: provider) }

        its(:program_type) { should eq("scitt_programme") }
      end

      context "a HEIs self accredited courses" do
        let(:subject) { create(:course) }
        its(:program_type) { should eq("higher_education_programme") }
      end
    end
  end
end
