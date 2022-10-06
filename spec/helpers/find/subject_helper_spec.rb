# frozen_string_literal: true

require "rails_helper"

describe Find::SubjectHelper, type: :helper do
  describe "#secondary_subject_options" do
    let(:subjects) { [find_or_create(:secondary_subject, :english)] }

    subject { secondary_subject_options(subjects) }

    it "returns secondary subject code" do
      expect(subject.first.code).to eq subjects.first.subject_code
    end

    it "returns secondary subject name" do
      expect(subject.first.name).to eq subjects.first.subject_name
    end

    it "returns no financial information" do
      expect(subject.first.financial_info).to be_nil
    end

    context "bursaries and scholarships is announced" do
      before do
        allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(true)
      end

      context "with bursary only" do
        let(:subjects) { [find_or_create(:secondary_subject, :biology)] }

        it "returns the correct financial information" do
          expect(subject.first.financial_info).to eq("Bursaries of £7,000 available")
        end
      end

      context "with scholarship only" do
        let(:subjects) { [find_or_create(:secondary_subject, subject_name: "made up subject", scholarship: 1000000000)] }

        it "returns the correct financial information" do
          expect(subject.first.financial_info).to eq("Scholarships of £1,000,000,000 are available")
        end
      end

      context "with scholarship and bursary" do
        let(:subjects) { [find_or_create(:secondary_subject, :chemistry)] }

        it "returns the correct financial information" do
          expect(subject.first.financial_info).to eq("Scholarships of £26,000 and bursaries of £24,000 are available")
        end
      end

      context "bursaries and scholarships is not announced" do
        before do
          allow(Settings.find_features).to receive(:bursaries_and_scholarships_announced).and_return(false)
        end

        context "with bursary only" do
          let(:subjects) { [find_or_create(:secondary_subject, :biology)] }

          it "returns the correct financial information" do
            expect(subject.first.financial_info).to be_nil
          end
        end

        context "with scholarship only" do
          let(:subjects) { [find_or_create(:secondary_subject, subject_name: "made up subject", scholarship: 1000000000)] }

          it "returns the correct financial information" do
            expect(subject.first.financial_info).to be_nil
          end
        end

        context "with scholarship and bursary" do
          let(:subjects) { [find_or_create(:secondary_subject, :chemistry)] }

          it "returns the correct financial information" do
            expect(subject.first.financial_info).to be_nil
          end
        end
      end
    end
  end
end
