# frozen_string_literal: true

require "rails_helper"

describe CourseSubject do
  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:subject) }
  end

  describe "validations" do
    describe "position on create" do
      let(:course) { build(:course, infer_subjects?: false) }
      let(:subject_record) { find_or_create(:secondary_subject, :biology) }

      it "is valid with a position of 0" do
        cs = described_class.new(course:, subject: subject_record, position: 0)
        expect(cs).to be_valid(:create)
      end

      it "is valid with a positive position" do
        cs = described_class.new(course:, subject: subject_record, position: 3)
        expect(cs).to be_valid(:create)
      end

      it "is invalid without a position" do
        cs = described_class.new(course:, subject: subject_record, position: nil)
        expect(cs).not_to be_valid(:create)
      end

      it "is invalid with a negative position" do
        cs = described_class.new(course:, subject: subject_record, position: -1)
        expect(cs).not_to be_valid(:create)
      end

      it "is invalid with a duplicate position for the same course" do
        described_class.create!(course:, subject: subject_record, position: 0)
        other_subject = find_or_create(:secondary_subject, :chemistry)
        cs = described_class.new(course:, subject: other_subject, position: 0)
        expect(cs).not_to be_valid(:create)
      end
    end
  end

  describe "auditing" do
    it { is_expected.to be_audited }
  end
end
