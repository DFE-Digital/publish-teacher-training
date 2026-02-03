# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ALevelsWizard#next_step", type: :wizard do
  include_context "a_levels_wizard"

  context "from what_a_level_is_required" do
    # Tests for navigation from what_a_level_is_required
  end

  context "from add_a_level_to_a_list" do
    # Tests for conditional edge based on another_a_level_needed?
  end

  context "from remove_a_level_subject_confirmation" do
    let(:current_step) { :remove_a_level_subject_confirmation }

    context "when A-levels remain after removal" do
      let(:a_level_subject_requirements) do
        [
          { "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" },
          { "uuid" => "456", "subject" => "physics", "minimum_grade_required" => "B" },
        ]
      end

      it "branches to add_a_level_to_a_list" do
        expect(wizard).to branch_from(:remove_a_level_subject_confirmation)
          .to(:add_a_level_to_a_list)
      end
    end

    context "when no A-levels remain after removal" do
      let(:a_level_subject_requirements) { [] }

      it "branches to course_edit" do
        expect(wizard).to branch_from(:remove_a_level_subject_confirmation)
          .to(:course_edit)
      end
    end
  end

  context "from consider_pending_a_level" do
    # Tests for navigation from consider_pending_a_level
  end

  context "from a_level_equivalencies" do
    # Tests for navigation from a_level_equivalencies
  end
end
