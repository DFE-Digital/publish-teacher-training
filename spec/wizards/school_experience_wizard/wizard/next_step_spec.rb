# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SchoolExperienceWizard#next_step", type: :wizard do
  include_context "school_experience_wizard"

  context "from experience_required" do
    let(:current_step) { :experience_required }

    context "when experience is required" do
      let(:school_experience_required) { true }

      it "branches to experience_details" do
        expect(wizard).to branch_from(:experience_required).to(:experience_details)
      end
    end

    context "when experience is not required" do
      let(:school_experience_required) { false }

      it "branches to course_edit" do
        expect(wizard).to branch_from(:experience_required).to(:course_edit)
      end
    end

    context "when no answer is given" do
      let(:school_experience_required) { nil }

      it "branches to course_edit" do
        expect(wizard).to branch_from(:experience_required).to(:course_edit)
      end
    end
  end

  context "from experience_details" do
    let(:current_step) { :experience_details }
    let(:school_experience_required) { true }

    it "proceeds to course_edit" do
      expect(wizard).to have_next_step(:course_edit)
    end
  end
end
