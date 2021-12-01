require "rails_helper"

RSpec.describe Course, type: :model do
  describe "#funding_type=" do
    before do
      subject.funding_type = funding_type
    end

    describe "when funding type is salary" do
      let(:funding_type) { "salary" }

      context "an externally accredited courses" do
        subject { create(:course, :with_accrediting_provider) }

        its(:program_type) { is_expected.to eq("school_direct_salaried_training_programme") }
      end

      context "a self accredited course" do
        subject { create(:course, :self_accredited) }

        it "does not error course object when updated to salaried course" do
          subject.update(program_type: "school_direct_salaried_training_programme")
          expect(subject.errors.count).to eq 0
        end
      end
    end

    describe "when funding type is apprenticeship" do
      subject { create(:course, :with_scitt) }

      let(:funding_type) { "apprenticeship" }

      its(:program_type) { is_expected.to eq("pg_teaching_apprenticeship") }
    end

    describe "when funding type is fee" do
      let(:funding_type) { "fee" }

      context "an externally accredited course" do
        subject { create(:course, :with_accrediting_provider) }

        its(:program_type) { is_expected.to eq("school_direct_training_programme") }
      end

      context "a SCITTs self accredited courses" do
        let(:provider) { build(:provider, :scitt) }

        subject { create(:course, provider: provider) }

        its(:program_type) {
          is_expected.to eq("scitt_programme")
        }
      end

      context "a HEIs self accredited courses" do
        let(:provider) { build(:provider, :university) }

        subject { create(:course, provider: provider) }

        its(:program_type) { is_expected.to eq("higher_education_programme") }
      end
    end
  end
end
