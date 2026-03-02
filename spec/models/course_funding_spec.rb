# frozen_string_literal: true

require "rails_helper"

describe CourseFunding do
  describe "constants" do
    describe "BURSARY_EXCLUDED_COURSE_PATTERNS" do
      it "contains the expected patterns" do
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS).to eq(
          [/^Drama/, /^Media Studies/, /^PE/, /^Physical/],
        )
      end

      it "matches expected course names" do
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS.first).to match("Drama with English")
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS[1]).to match("Media Studies with English")
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS[2]).to match("PE with Mathematics")
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS[3]).to match("Physical Education with Mathematics")
      end

      it "does not match non-excluded course names" do
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS.first).not_to match("Mathematics with Physics")
      end

      it "is frozen" do
        expect(described_class::BURSARY_EXCLUDED_COURSE_PATTERNS).to be_frozen
      end
    end
  end

  describe "#financial_incentive" do
    it "returns the first non-Modern-Languages subject's financial incentive" do
      subject = build(:secondary_subject, :mathematics, bursary_amount: "3000")
      course = build(:course, subjects: [subject])

      funding = described_class.new(course)

      expect(funding.financial_incentive).to eq(subject.financial_incentive)
    end

    it "skips Modern Languages subject" do
      ml_subject = build(:secondary_subject, :modern_languages, bursary_amount: "1000")
      real_subject = build(:secondary_subject, :french, bursary_amount: "3000")
      course = build(:course, subjects: [ml_subject, real_subject])

      funding = described_class.new(course)

      expect(funding.financial_incentive).to eq(real_subject.financial_incentive)
    end

    it "returns nil when no subjects have financial incentives" do
      subject = build(:secondary_subject, :mathematics)
      course = build(:course, subjects: [subject])

      funding = described_class.new(course)

      expect(funding.financial_incentive.bursary_amount).to be_nil
    end
  end

  describe "#bursary_amount" do
    it "returns the bursary amount from the financial incentive" do
      subject = build(:secondary_subject, bursary_amount: "3000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course).bursary_amount).to eq("3000")
    end

    it "returns nil when there is no bursary" do
      subject = build(:secondary_subject)
      course = build(:course, subjects: [subject])

      expect(described_class.new(course).bursary_amount).to be_nil
    end
  end

  describe "#scholarship_amount" do
    it "returns the scholarship amount from the financial incentive" do
      subject = build(:secondary_subject, scholarship: "2000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course).scholarship_amount).to eq("2000")
    end
  end

  describe "#has_bursary?" do
    it "returns true when bursary amount is present" do
      subject = build(:secondary_subject, bursary_amount: "3000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).to be_has_bursary
    end

    it "returns false when bursary amount is nil" do
      subject = build(:secondary_subject)
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).not_to be_has_bursary
    end
  end

  describe "#has_scholarship?" do
    it "returns true when scholarship amount is present" do
      subject = build(:secondary_subject, scholarship: "2000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).to be_has_scholarship
    end

    it "returns false when scholarship amount is nil" do
      subject = build(:secondary_subject)
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).not_to be_has_scholarship
    end
  end

  describe "#has_scholarship_and_bursary?" do
    it "returns true when both are present" do
      subject = build(:secondary_subject, bursary_amount: "3000", scholarship: "2000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).to be_has_scholarship_and_bursary
    end

    it "returns false when only bursary is present" do
      subject = build(:secondary_subject, bursary_amount: "3000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).not_to be_has_scholarship_and_bursary
    end
  end

  describe "#has_early_career_payments?" do
    it "returns true when early career payments are present" do
      subject = build(:secondary_subject, bursary_amount: "3000")
      subject.financial_incentive.update!(early_career_payments: "2000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).to be_has_early_career_payments
    end

    it "returns false when no early career payments" do
      subject = build(:secondary_subject)
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).not_to be_has_early_career_payments
    end
  end

  describe "#max_bursary_amount" do
    it "returns the maximum bursary amount across all subjects" do
      mathematics = build(:secondary_subject, bursary_amount: "2000")
      english = build(:secondary_subject, bursary_amount: "4000")
      course = build(:course, :secondary, subjects: [mathematics, english])

      expect(described_class.new(course).max_bursary_amount).to eq("4000")
    end
  end

  describe "#max_scholarship_amount" do
    it "returns the maximum scholarship amount across all subjects" do
      mathematics = build(:secondary_subject, scholarship: "2000")
      english = build(:secondary_subject, scholarship: "4000")
      course = build(:course, :secondary, subjects: [mathematics, english])

      expect(described_class.new(course).max_scholarship_amount).to eq("4000")
    end
  end

  describe "#bursary_only?" do
    it "returns true when course has bursary but not scholarship" do
      subject = build(:secondary_subject, bursary_amount: "3000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).to be_bursary_only
    end

    it "returns false when course has both bursary and scholarship" do
      subject = build(:secondary_subject, bursary_amount: "3000", scholarship: "2000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course)).not_to be_bursary_only
    end
  end

  describe "#excluded_from_bursary?" do
    it "returns false for single-subject courses" do
      course = build_stubbed(:course, name: "Mathematics")
      allow(course).to receive(:subjects).and_return([build_stubbed(:secondary_subject)])

      expect(described_class.new(course)).not_to be_excluded_from_bursary
    end

    context "course name contains 'with'" do
      let(:english) { build_stubbed(:secondary_subject, bursary_amount: "30000") }
      let(:drama) { build_stubbed(:secondary_subject, subject_name: "Drama") }
      let(:subjects) { [english, drama] }

      it "excludes 'Drama with English'" do
        course = build_stubbed(:course, name: "Drama with English")
        allow(course).to receive(:subjects).and_return(subjects)

        expect(described_class.new(course)).to be_excluded_from_bursary
      end

      it "does not exclude 'English with Drama'" do
        course = build_stubbed(:course, name: "English with Drama")
        allow(course).to receive(:subjects).and_return(subjects)

        expect(described_class.new(course)).not_to be_excluded_from_bursary
      end
    end

    context "course name contains 'and'" do
      let(:english) { build_stubbed(:secondary_subject, bursary_amount: "30000") }
      let(:drama) { build_stubbed(:secondary_subject, subject_name: "Drama") }
      let(:subjects) { [english, drama] }

      it "does not exclude 'Drama and English'" do
        course = build_stubbed(:course, name: "Drama and English")
        allow(course).to receive(:subjects).and_return(subjects)

        expect(described_class.new(course)).not_to be_excluded_from_bursary
      end
    end
  end

  describe "#bursary_eligible_subjects?" do
    it "returns true when course has a subject with non_uk_bursary_eligible flag" do
      italian = build(:secondary_subject, subject_name: "Italian", non_uk_bursary_eligible: true)
      course = build(:course, subjects: [italian])

      expect(described_class.new(course)).to be_bursary_eligible_subjects
    end

    it "returns false when no subjects have the flag" do
      maths = build(:secondary_subject, subject_name: "Mathematics")
      course = build(:course, subjects: [maths])

      expect(described_class.new(course)).not_to be_bursary_eligible_subjects
    end
  end

  describe "#scholarship_eligible_subjects?" do
    it "returns true when course has a subject with non_uk_scholarship_eligible flag" do
      physics = build(:secondary_subject, subject_name: "Physics", non_uk_scholarship_eligible: true)
      course = build(:course, subjects: [physics])

      expect(described_class.new(course)).to be_scholarship_eligible_subjects
    end

    it "returns false when no subjects have the flag" do
      maths = build(:secondary_subject, subject_name: "Mathematics")
      course = build(:course, subjects: [maths])

      expect(described_class.new(course)).not_to be_scholarship_eligible_subjects
    end
  end

  describe "#non_uk_funding_available?" do
    it "returns true when bursary eligible" do
      italian = build(:secondary_subject, subject_name: "Italian", non_uk_bursary_eligible: true)
      course = build(:course, subjects: [italian])

      expect(described_class.new(course)).to be_non_uk_funding_available
    end

    it "returns true when scholarship eligible" do
      physics = build(:secondary_subject, subject_name: "Physics", non_uk_scholarship_eligible: true)
      course = build(:course, subjects: [physics])

      expect(described_class.new(course)).to be_non_uk_funding_available
    end

    it "returns false when neither flag is set" do
      maths = build(:secondary_subject, subject_name: "Mathematics")
      course = build(:course, subjects: [maths])

      expect(described_class.new(course)).not_to be_non_uk_funding_available
    end
  end

  describe "#subject_with_scholarship" do
    it "returns the downcased subject name for a subject with a scholarship" do
      physics = build(:secondary_subject, :physics, scholarship: "31000")
      course = build(:course, subjects: [physics])

      expect(described_class.new(course).subject_with_scholarship).to eq("physics")
    end

    it "returns nil when no subject has a scholarship" do
      history = build(:secondary_subject, :history)
      course = build(:course, subjects: [history])

      expect(described_class.new(course).subject_with_scholarship).to be_nil
    end
  end
end
