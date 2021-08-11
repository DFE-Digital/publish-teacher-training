require "rails_helper"

describe RequiredQualificationsSummary, type: :model do
  describe "#extract" do
    context "when a published required_qualifications enrichment attribute is present" do
      let(:enrichment) { build(:course_enrichment, :published, required_qualifications: "GCSE Computer Science") }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "returns the value of required_qualifications" do
        summary = described_class.new(course).extract
        expect(summary).to eq "GCSE Computer Science"
      end
    end

    context "when required_qualifications enrichment attribute is blank" do
      it "assembles a whole summary based on course attributes" do
        course = create(:course, :primary)
        summary = described_class.new(course).extract

        expect(summary).to eq <<~SUMMARY.strip
          Grade 4 (C) or above in English, maths and science, or equivalent qualification.
          We will not consider candidates with pending GCSEs.
          We do not accept equivalency tests.

          An undergraduate degree at class 2:1 or above, or equivalent.
          Completed at least one programming module.
        SUMMARY
      end

      it "includes science as a required GCSE if course is primary" do
        course = create(:course, :primary)
        summary = described_class.new(course).extract

        expect(summary).to include "Grade 4 (C) or above in English, maths and science, or equivalent qualification"
        expect(summary).not_to include "Grade 4 (C) or above in English and maths, or equivalent qualification"
      end

      it "specifies a GCSE grade requirement defined by the course" do
        course = create(:course, :primary)
        allow(course).to receive(:gcse_grade_required).and_return 5
        summary = described_class.new(course).extract

        expect(summary).to include "Grade 5 (C) or above in English, maths and science, or equivalent qualification"
        expect(summary).not_to include "Grade 5 (C) or above in English and maths, or equivalent qualification"
      end

      it "does not mention science as a required GCSE if course is secondary" do
        course = create(:course, :secondary)
        summary = described_class.new(course).extract

        expect(summary).not_to include "Grade 4 (C) or above in English, maths and science, or equivalent qualification"
        expect(summary).to include "Grade 4 (C) or above in English and maths, or equivalent qualification"
      end

      it "does not include required GCSE content if course is neither primary or secondary" do
        course = create(:course, level: :further_education)
        summary = described_class.new(course).extract

        expect(summary).not_to include "Grade 4 (C) or above in English, maths and science, or equivalent qualification"
        expect(summary).not_to include "Grade 4 (C) or above in English and maths, or equivalent qualification"
      end

      it "states pending GCSEs will be considered if accept_pending_gcse? is true" do
        course = create(:course, accept_pending_gcse: true)
        summary = described_class.new(course).extract

        expect(summary).to include "We will consider candidates with pending GCSEs"
      end

      it "states pending GCSEs will NOT be considered if accept_pending_gcse? is false" do
        course = create(:course, accept_pending_gcse: false)
        summary = described_class.new(course).extract

        expect(summary).to include "We will not consider candidates with pending GCSEs"
      end

      context "course.accept_gcse_equivalency? is false" do
        let(:course) { create(:course, accept_gcse_equivalency: false) }

        it "states equivalency tests not accepted" do
          summary = described_class.new(course).extract

          expect(summary).to include "We do not accept equivalency tests"
        end
      end

      context "course.accept_gcse_equivalency? is true" do
        let(:course) { create(:course, accept_gcse_equivalency: true) }

        it "states one equivalency accepted if only one accepted" do
          course.update!(accept_english_gcse_equivalency: true)
          summary = described_class.new(course).extract

          expect(summary).to include "We will accept equivalency tests in English"
        end

        it "states two equivalencies accepted if two accepted" do
          course.update!(accept_english_gcse_equivalency: true, accept_maths_gcse_equivalency: true)
          summary = described_class.new(course).extract

          expect(summary).to include "We will accept equivalency tests in English and maths"
        end

        it "states three equivalencies accepted if three accepted" do
          course.update!(
            accept_english_gcse_equivalency: true,
            accept_maths_gcse_equivalency: true,
            accept_science_gcse_equivalency: true,
          )
          summary = described_class.new(course).extract

          expect(summary).to include "We will accept equivalency tests in English, maths and science"
        end

        it "shows additional GCSE equivalencies if present" do
          course.update!(additional_gcse_equivalencies: "Some additional GCSE equivalencies")
          summary = described_class.new(course).extract

          expect(summary).to include "Some additional GCSE equivalencies"
        end
      end

      it "states the appropriate degree grade requirement" do
        course = create(:course)
        mapping = [
          ["two_one", "An undergraduate degree at class 2:1 or above, or equivalent."],
          ["two_two", "An undergraduate degree at class 2:2 or above, or equivalent."],
          ["third_class", "An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent."],
          ["not_required", "An undergraduate degree, or equivalent."],
        ]

        mapping.each do |grade, sentence|
          course.update!(degree_grade: grade)
          summary = described_class.new(course).extract

          expect(summary).to include sentence
        end

        course.update!(degree_grade: nil)
        summary = described_class.new(course).extract
        mapping.each { |_, sentence| expect(summary).not_to include sentence }
      end

      it "displays additional_degree_subject_requirements if there are any" do
        course = create(:course, additional_degree_subject_requirements: true, degree_subject_requirements: "Can spell gud")
        summary = described_class.new(course).extract
        expect(summary).to include "Can spell gud"
      end
    end
  end
end
