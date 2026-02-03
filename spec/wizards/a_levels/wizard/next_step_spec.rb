# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ALevelsWizard#next_step", type: :wizard do
  include_context "a_levels_wizard"

  context "from what_a_level_is_required" do
    let(:current_step) { :what_a_level_is_required }

    it "proceeds to add_a_level_to_a_list" do
      expect(wizard).to have_next_step(:add_a_level_to_a_list)
    end
  end

  context "from add_a_level_to_a_list" do
    let(:current_step) { :add_a_level_to_a_list }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    context "when adding another A-level" do
      before do
        state_store.write(add_another_a_level: "yes")
      end

      it "branches to what_a_level_is_required" do
        expect(wizard).to branch_from(:add_a_level_to_a_list)
          .to(:what_a_level_is_required)
      end
    end

    context "when not adding another A-level" do
      before do
        state_store.write(add_another_a_level: "no")
      end

      it "branches to consider_pending_a_level" do
        expect(wizard).to branch_from(:add_a_level_to_a_list)
          .to(:consider_pending_a_level)
      end
    end
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
    let(:current_step) { :consider_pending_a_level }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    it "proceeds to a_level_equivalencies" do
      expect(wizard).to have_next_step(:a_level_equivalencies)
    end
  end

  context "from a_level_equivalencies" do
    let(:current_step) { :a_level_equivalencies }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    it "proceeds to course_edit" do
      expect(wizard).to have_next_step(:course_edit)
    end
  end
end
