# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::StartDate do
  subject(:wizard_step) { wizard.current_step }

  include_context "add_course_wizard"

  let(:current_step) { :start_date }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
  let(:current_step_params) { { start_date: } }
  let(:start_date) { nil }

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: cycle_year) }
  let(:cycle_year) { 2026 }
  let(:provider) { create(:provider, :accredited_provider, recruitment_cycle:) }

  describe "#valid?" do
    context "when start_date is present" do
      it "is valid" do
        wizard_step.start_date = "January 2026"
        expect(wizard_step).to be_valid
      end
    end

    context "when start_date is not present" do
      it "is not valid" do
        wizard_step.start_date = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.messages_for(:start_date)).to contain_exactly("Select a course start date")
      end
    end
  end

  describe "#start_date_options" do
    it "starts from the current month when in the recruitment cycle year" do
      travel_to Date.new(2026, 6, 15) do
        options = wizard_step.start_date_options

        expect(options.first).to eq("June 2026")
        expect(options).to include("July 2027")
        expect(options).not_to include("May 2026")
      end
    end

    context "when today is after the recruitment cycle year" do
      it "falls back to January of the cycle year" do
        travel_to Date.new(2027, 2, 1) do
          options = wizard_step.start_date_options

          expect(options.first).to eq("January 2026")
          expect(options).to include("July 2027")
          expect(options).to include("February 2026")
        end
      end
    end

    context "when the recruitment cycle year is in the future" do
      let(:cycle_year) { 2027 }

      it "starts from January of the cycle year" do
        travel_to Date.new(2026, 6, 15) do
          options = wizard_step.start_date_options

          expect(options.first).to eq("January 2027")
          expect(options).to include("July 2028")
          expect(options).not_to include("December 2026")
        end
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[start_date])
    end
  end
end
