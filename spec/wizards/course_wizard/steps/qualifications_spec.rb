# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::Qualifications do
  include_context "add_course_wizard"

  let(:current_step) { :qualifications }
  let(:current_step_params) { { qualification: } }
  let(:qualification) { nil }

  describe "#valid?" do
    subject(:wizard_step) { wizard.current_step }

    context "when qualification is not present" do
      it "adds a select a qualification error" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:qualification)).to contain_exactly("Select a qualification")
      end
    end

    context "when further education level is selected and qualification has qts" do
      let(:qualification) { "qts" }

      before do
        state_store.write(level: "further_education")
      end

      it "is not valid" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:qualification)).to contain_exactly("Select a qualification")
      end
    end

    context "when qualification is not in the list of options" do
      let(:qualification) { "invalid" }

      it "is not valid" do
        wizard_step.valid?

        expect(wizard_step.errors.messages_for(:qualification)).to contain_exactly("Select a qualification")
      end
    end
  end

  describe "#qualification_options" do
    subject(:wizard_step) { wizard.current_step }

    context "when level is primary" do
      before do
        state_store.write(level: "primary")
      end

      it "returns qualifications with qts" do
        expect(wizard_step.qualification_options).to eq(%w[pgce_with_qts pgde_with_qts qts undergraduate_degree_with_qts])
      end
    end

    context "when level is further education" do
      before do
        state_store.write(level: "further_education")
      end

      it "returns qualifications without qts" do
        expect(wizard_step.qualification_options).to eq(%w[pgce pgde])
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq([:qualification])
    end
  end
end
