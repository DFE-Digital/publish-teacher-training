# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::AgeRange do
  subject(:wizard_step) do
    described_class.new(
      age_range_in_years:,
      course_age_range_in_years_other_from: from_age,
      course_age_range_in_years_other_to: to_age,
    )
  end

  let(:age_range_in_years) { "other" }

  describe "#valid?" do
    context "when age_range_in_years is not present" do
      let(:age_range_in_years) { nil }
      let(:from_age) { nil }
      let(:to_age) { nil }

      it "adds the select an age range error" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:age_range_in_years)).to contain_exactly("Select an age range")
      end
    end

    context "when the custom range is valid" do
      let(:from_age) { "5" }
      let(:to_age) { "11" }

      it "is valid" do
        expect(wizard_step).to be_valid
      end
    end

    context "when the custom range is outside allowed school year bounds" do
      let(:from_age) { "2" }
      let(:to_age) { "11" }

      it "adds a shared service error to age_range_in_years" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:age_range_in_years)).to contain_exactly("Age range must cover 4 or more school years")
      end
    end

    context "when the custom range is shorter than four years" do
      let(:from_age) { "8" }
      let(:to_age) { "11" }

      it "adds a shared service error to age_range_in_years" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:age_range_in_years)).to contain_exactly("Age range must cover at least 4 years")
      end
    end

    context "when custom inputs are not numeric" do
      let(:from_age) { "x" }
      let(:to_age) { "11" }

      it "keeps field-level numeric validation errors" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:course_age_range_in_years_other_from)).to include("Enter a valid age in From")
        expect(wizard_step.errors.messages_for(:age_range_in_years)).to be_empty
      end
    end
  end
end
