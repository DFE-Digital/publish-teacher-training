# frozen_string_literal: true

require "rails_helper"

module Find
  describe SubjectsForm, type: :model do
    subject { described_class.new(params) }

    describe "validations" do
      before { subject.valid? }

      context "subject_codes is blank" do
        let(:params) { { subject_codes: [] } }

        it "raises the correct error" do
          expect(subject.errors[:subject_codes]).to include("Select at least one subject")
        end
      end

      context "subject_codes are valid" do
        let(:params) { { subject_codes: %w[01 02] } }

        it "validates subject_codes" do
          expect(subject.errors[:subject_codes]).to eq []
        end
      end
    end

    describe ".primary_subjects" do
      let(:params) { { subject_codes: %w[01 02] } }

      it "is an instance method" do
        expect(subject).to respond_to(:primary_subjects)
      end

      it "returns an array of Structs" do
        expect(subject.primary_subjects[0].is_a?(Struct)).to be true
        expect(subject.primary_subjects[0].code).to eq "00"
        expect(subject.primary_subjects[0].name).to eq "Primary"
      end
    end
  end
end
