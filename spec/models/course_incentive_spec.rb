# frozen_string_literal: true

require "rails_helper"

describe CourseIncentive do
  before { FeatureFlag.activate(:bursaries_and_scholarships_announced) }

  shared_context "modern languages with subordinate subject" do
    let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
    let(:mandarin) do
      build(:modern_languages_subject, :mandarin).tap do |s|
        s.financial_incentive = FinancialIncentive.new(
          bursary_amount: "20000",
          scholarship: "22000",
          non_uk_bursary_eligible: true,
          non_uk_scholarship_eligible: true,
        )
      end
    end
    let(:mathematics) do
      build(:secondary_subject, bursary_amount: "29000", scholarship: "31000",
                                non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
    end
    let(:course) do
      build(:course, :secondary, name: "Modern Languages (Mandarin) with Mathematics",
                                 subjects: [modern_languages, mandarin, mathematics],
                                 master_subject_id: modern_languages.id,
                                 subordinate_subject_id: mathematics.id)
    end
    let(:funding) { described_class.new(course) }
  end

  shared_context "modern languages without universal scholarship" do
    let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
    let(:language_with_scholarship) do
      build(:modern_languages_subject, subject_name: "Language With Scholarship", subject_code: "15").tap do |s|
        s.financial_incentive = FinancialIncentive.new(
          bursary_amount: "20000",
          scholarship: "22000",
          non_uk_bursary_eligible: true,
          non_uk_scholarship_eligible: true,
        )
      end
    end
    let(:language_without_scholarship) do
      build(:modern_languages_subject, subject_name: "Language Without Scholarship", subject_code: "19").tap do |s|
        s.financial_incentive = FinancialIncentive.new(
          bursary_amount: "20000",
          non_uk_bursary_eligible: true,
        )
      end
    end
    let(:course) do
      build(:course, :secondary, name: "Modern Languages",
                                 subjects: [modern_languages, language_with_scholarship, language_without_scholarship],
                                 master_subject_id: modern_languages.id)
    end
    let(:funding) { described_class.new(course) }
  end

  shared_context "course with subordinate subject" do
    let(:master) do
      build(:secondary_subject, subject_name: "Drama")
    end
    let(:subordinate) do
      build(:secondary_subject, bursary_amount: "30000", scholarship: "26000",
                                non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
    end
    let(:course_name) { "Drama with English" }
    let(:course) do
      build(:course, :secondary, name: course_name,
                                 subjects: [master, subordinate],
                                 master_subject_id: master.id,
                                 subordinate_subject_id: subordinate.id)
    end
    let(:funding) { described_class.new(course) }
  end

  describe "salaried and apprenticeship courses" do
    it "returns no funding for salaried courses" do
      subject = build(:secondary_subject, bursary_amount: "3000", scholarship: "2000")
      course = build(:course, :salary, subjects: [subject])
      funding = described_class.new(course)

      expect(funding.bursary_amount).to be_nil
      expect(funding.scholarship_amount).to be_nil
      expect(funding).not_to be_has_bursary
      expect(funding).not_to be_has_scholarship
    end

    it "returns no funding for apprenticeship courses" do
      subject = build(:secondary_subject, bursary_amount: "3000", scholarship: "2000")
      course = build(:course, :apprenticeship, subjects: [subject])
      funding = described_class.new(course)

      expect(funding.bursary_amount).to be_nil
      expect(funding.scholarship_amount).to be_nil
      expect(funding).not_to be_has_bursary
      expect(funding).not_to be_has_scholarship
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

    context "when Modern Languages is the master subject" do
      include_context "modern languages with subordinate subject"

      it "returns the language subject's bursary, not the subordinate's" do
        expect(funding.bursary_amount).to eq("20000")
      end

      it "uses the max across multiple language subjects" do
        russian = build(:modern_languages_subject, :russian).tap do |s|
          s.financial_incentive = FinancialIncentive.new(bursary_amount: "25000")
        end
        ml_course = build(:course, :secondary, name: "Modern Languages (Mandarin and Russian) with Mathematics",
                                               subjects: [modern_languages, mandarin, russian, mathematics],
                                               master_subject_id: modern_languages.id,
                                               subordinate_subject_id: mathematics.id)

        expect(described_class.new(ml_course).bursary_amount).to eq("25000")
      end
    end
  end

  describe "#scholarship_amount" do
    it "returns the scholarship amount from the financial incentive" do
      subject = build(:secondary_subject, scholarship: "2000")
      course = build(:course, subjects: [subject])

      expect(described_class.new(course).scholarship_amount).to eq("2000")
    end

    context "when Modern Languages is the master subject" do
      include_context "modern languages with subordinate subject"

      it "returns the language subject's scholarship, not the subordinate's" do
        expect(funding.scholarship_amount).to eq("22000")
      end
    end

    context "when any language subject does not offer a scholarship" do
      include_context "modern languages without universal scholarship"

      it "returns nil" do
        expect(funding.scholarship_amount).to be_nil
      end
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

    context "when any language subject does not offer a scholarship" do
      include_context "modern languages without universal scholarship"

      it "returns false" do
        expect(funding).not_to be_has_scholarship
      end
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

    context "when Modern Languages is the master subject" do
      include_context "modern languages with subordinate subject"

      it "ignores the subordinate subject's eligibility" do
        mandarin.financial_incentive.non_uk_bursary_eligible = false

        expect(funding).not_to be_bursary_eligible_subjects
      end
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

    context "when Modern Languages is the master subject" do
      include_context "modern languages with subordinate subject"

      it "ignores the subordinate subject's eligibility" do
        mandarin.financial_incentive.non_uk_scholarship_eligible = false

        expect(funding).not_to be_scholarship_eligible_subjects
      end
    end

    context "when any language subject does not offer a scholarship" do
      include_context "modern languages without universal scholarship"

      it "returns false" do
        expect(funding).not_to be_scholarship_eligible_subjects
      end
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

  describe "subordinate subject exclusion" do
    context "when course has a subordinate subject with no master bursary" do
      include_context "course with subordinate subject"

      it "ignores the subordinate subject's bursary" do
        expect(funding.bursary_amount).to be_nil
      end

      it "ignores the subordinate subject's scholarship" do
        expect(funding.scholarship_amount).to be_nil
      end

      it "ignores the subordinate subject's non-UK bursary eligibility" do
        expect(funding).not_to be_bursary_eligible_subjects
      end

      it "ignores the subordinate subject's non-UK scholarship eligibility" do
        expect(funding).not_to be_scholarship_eligible_subjects
      end
    end

    context "when course has a subordinate subject and master has bursary" do
      let(:master) { build(:secondary_subject, subject_name: "Mathematics", bursary_amount: "25000") }
      let(:subordinate) { build(:secondary_subject, subject_name: "Physics", bursary_amount: "29000", scholarship: "31000") }
      let(:course) do
        build(:course, :secondary, name: "Mathematics with Physics",
                                   subjects: [master, subordinate],
                                   master_subject_id: master.id,
                                   subordinate_subject_id: subordinate.id)
      end
      let(:funding) { described_class.new(course) }

      it "uses the master subject's bursary, not the subordinate's" do
        expect(funding.bursary_amount).to eq("25000")
      end

      it "does not use the subordinate's scholarship" do
        expect(funding).not_to be_has_scholarship
      end
    end

    context "when Modern Languages is master with subordinate" do
      include_context "modern languages with subordinate subject"

      it "uses language subjects, ignoring both ML parent and subordinate" do
        expect(funding.bursary_amount).to eq("20000")
        expect(funding.scholarship_amount).to eq("22000")
      end

      it "ignores the subordinate's non-UK eligibility" do
        mandarin.financial_incentive.non_uk_bursary_eligible = false
        expect(funding).not_to be_bursary_eligible_subjects
      end
    end

    context "when Modern Languages is master without subordinate" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:french) do
        build(:modern_languages_subject, :french).tap do |s|
          s.financial_incentive = FinancialIncentive.new(bursary_amount: "20000")
        end
      end
      let(:course) do
        build(:course, :secondary, subjects: [modern_languages, french],
                                   master_subject_id: modern_languages.id)
      end

      it "uses language subjects" do
        expect(described_class.new(course).bursary_amount).to eq("20000")
      end
    end
  end

  context "when Science is master with a specialist subordinate" do
    shared_context "science with specialist subordinate" do |specialist_name|
      let(:science) { build(:secondary_subject, subject_name: "Science") }
      let(:specialist) do
        build(:secondary_subject, subject_name: specialist_name,
                                  bursary_amount: "29000", scholarship: "31000",
                                  non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
      end
      let(:course) do
        build(:course, :secondary, name: "Science with #{specialist_name}",
                                   subjects: [science, specialist],
                                   master_subject_id: science.id,
                                   subordinate_subject_id: specialist.id)
      end
      let(:funding) { described_class.new(course) }
    end

    %w[Physics Chemistry Biology].each do |specialist_name|
      context "when subordinate is #{specialist_name}" do
        include_context "science with specialist subordinate", specialist_name

        it "uses the subordinate's bursary" do
          expect(funding.bursary_amount).to eq("29000")
        end

        it "uses the subordinate's scholarship" do
          expect(funding.scholarship_amount).to eq("31000")
        end

        it "uses the subordinate's non-UK bursary eligibility" do
          expect(funding).to be_bursary_eligible_subjects
        end

        it "uses the subordinate's non-UK scholarship eligibility" do
          expect(funding).to be_scholarship_eligible_subjects
        end
      end
    end

    context "when subordinate is not a science specialist" do
      let(:science) { build(:secondary_subject, subject_name: "Science", bursary_amount: "10000") }
      let(:mathematics) { build(:secondary_subject, subject_name: "Mathematics", bursary_amount: "25000") }
      let(:course) do
        build(:course, :secondary, name: "Science with Mathematics",
                                   subjects: [science, mathematics],
                                   master_subject_id: science.id,
                                   subordinate_subject_id: mathematics.id)
      end
      let(:funding) { described_class.new(course) }

      it "uses the master's bursary" do
        expect(funding.bursary_amount).to eq("10000")
      end
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

    context "when Modern Languages is the master subject" do
      include_context "modern languages with subordinate subject"

      it "returns the language subject, not the subordinate" do
        expect(funding.subject_with_scholarship).to eq("mandarin")
      end
    end

    context "when any language subject does not offer a scholarship" do
      include_context "modern languages without universal scholarship"

      it "returns nil" do
        expect(funding.subject_with_scholarship).to be_nil
      end
    end
  end
end
