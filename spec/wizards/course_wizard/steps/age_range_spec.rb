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

  include_context "add_course_wizard"

  let(:age_range_in_years) { "other" }
  let(:from_age) { nil }
  let(:to_age) { nil }

  describe "#valid?" do
    context "when age_range_in_years is not present" do
      let(:age_range_in_years) { nil }

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

      it "adds a field-level bounds error on from age" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:course_age_range_in_years_other_from)).to include("From age must be between 3 and 15")
        expect(wizard_step.errors.messages_for(:age_range_in_years)).to be_empty
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

    context "when custom ages are outside the valid from and to range" do
      let(:from_age) { "20" }
      let(:to_age) { "30" }

      it "adds field-level bounds errors from the shared range limits" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:course_age_range_in_years_other_from)).to include("From age must be between 3 and 15")
        expect(wizard_step.errors.messages_for(:course_age_range_in_years_other_to)).to include("To age must be between 7 and 19")
        expect(wizard_step.errors.messages_for(:age_range_in_years)).to be_empty
      end
    end
  end

  describe "#preset_options" do
    subject(:wizard_step) { wizard.current_step }

    let(:current_step) { :age_range }

    context "when the selected level is primary" do
      before do
        state_store.write(level: "primary")
      end

      it "returns primary age range options" do
        expect(wizard_step.preset_options).to eq(%w[3_to_7 5_to_11 7_to_11 7_to_14])
      end
    end

    context "when the selected level is secondary" do
      before do
        state_store.write(level: "secondary")
      end

      it "returns secondary age range options" do
        expect(wizard_step.preset_options).to eq(%w[11_to_16 11_to_18 14_to_19])
      end
    end
  end
end
