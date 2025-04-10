# frozen_string_literal: true

require "rails_helper"

module Publish
  describe GcseRequirementsForm do
    describe "validations" do
      it "is invalid if no value is selected for accept_pending_gcse" do
        form = described_class.new(accept_pending_gcse: nil)
        expect(form.valid?).to be_falsey
      end

      it "is invalid if no value is selected for accept_gcse_equivalency" do
        form = described_class.new(accept_gcse_equivalency: nil)
        expect(form.valid?).to be_falsey
      end

      it "is invalid if accept_gcse_equivalency is true but no value is selected for equivalencies for primary course" do
        form = described_class.new(
          accept_gcse_equivalency: true, accept_english_gcse_equivalency: nil,
          accept_maths_gcse_equivalency: nil, accept_science_gcse_equivalency: nil,
          additional_gcse_equivalencies: nil, level: "primary"
        )
        expect(form.valid?).to be_falsey
        expect(form.errors[:equivalencies]).to be_present
      end

      it "is invalid if accept_gcse_equivalency is true but no value is selected for equivalencies for non primary course" do
        form = described_class.new(
          accept_gcse_equivalency: true, accept_english_gcse_equivalency: nil,
          accept_maths_gcse_equivalency: nil, accept_science_gcse_equivalency: nil,
          additional_gcse_equivalencies: nil, level: "secondary"
        )
        expect(form.valid?).to be_falsey
        expect(form.errors[:equivalencies]).to be_present
      end

      it "is invalid if no value is selected for additional_gcse_equivalencies" do
        form = described_class.new(
          accept_gcse_equivalency: true, accept_english_gcse_equivalency: nil,
          accept_maths_gcse_equivalency: nil, accept_science_gcse_equivalency: nil,
          additional_gcse_equivalencies: nil
        )
        expect(form.valid?).to be_falsey
        expect(form.errors[:additional_gcse_equivalencies]).to be_present
      end
    end

    describe "#save" do
      let(:course) { instance_double(Course) }

      it "returns false if invalid" do
        form = described_class.new(
          accept_pending_gcse: nil, accept_gcse_equivalency: nil, accept_english_gcse_equivalency: nil,
          accept_maths_gcse_equivalency: nil, accept_science_gcse_equivalency: nil,
          additional_gcse_equivalencies: nil
        )
        expect(form.save(course)).to be false
      end

      context "all values marked as true and completed" do
        it "returns true if valid" do
          allow(course).to receive(:update).and_return(true)

          form = described_class.new(
            accept_pending_gcse: true, accept_gcse_equivalency: true, accept_english_gcse_equivalency: true,
            accept_maths_gcse_equivalency: true, accept_science_gcse_equivalency: true,
            additional_gcse_equivalencies: "Geography"
          )
          expect(form.save(course)).to be true
        end
      end

      context "essential values marked as false" do
        it "returns true if valid" do
          allow(course).to receive(:update).and_return(true)

          form = described_class.new(
            accept_pending_gcse: false, accept_gcse_equivalency: false, accept_english_gcse_equivalency: nil,
            accept_maths_gcse_equivalency: nil, accept_science_gcse_equivalency: nil,
            additional_gcse_equivalencies: nil
          )
          expect(form.save(course)).to be true
        end
      end
    end

    describe "#build_from_course" do
      it "builds a new GcseRequirementsForm and sets the attrs based on the course" do
        course = build(
          :course,
          accept_pending_gcse: true, accept_gcse_equivalency: true, accept_english_gcse_equivalency: true,
          accept_maths_gcse_equivalency: true, accept_science_gcse_equivalency: true,
          additional_gcse_equivalencies: "Geography"
        )
        form = described_class.build_from_course(course)

        expect(form.accept_pending_gcse).to be true
        expect(form.accept_gcse_equivalency).to be true
        expect(form.accept_english_gcse_equivalency).to be true
        expect(form.accept_maths_gcse_equivalency).to be true
        expect(form.accept_science_gcse_equivalency).to be true
        expect(form.additional_gcse_equivalencies).to eq "Geography"
      end
    end
  end
end
