# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ALevelsWizard#previous_step", type: :wizard do
  include_context "a_levels_wizard"

  context "from what_a_level_is_required" do
    let(:current_step) { :what_a_level_is_required }
    let(:a_level_subject_requirements) { [] }

    it "has no previous step (root)" do
      expect(wizard).to have_previous_step(nil)
    end
  end

  context "from add_a_level_to_a_list" do
    let(:current_step) { :add_a_level_to_a_list }

    context "when it is the root step (A-levels already exist)" do
      let(:a_level_subject_requirements) do
        [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
      end

      it "has no previous step" do
        expect(wizard).to have_previous_step(nil)
      end
    end

    context "when reached from what_a_level_is_required" do
      let(:a_level_subject_requirements) { [] }

      it "returns to what_a_level_is_required" do
        expect(wizard).to have_previous_step(:what_a_level_is_required)
      end
    end
  end

  context "from remove_a_level_subject_confirmation" do
    let(:current_step) { :remove_a_level_subject_confirmation }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    # This step is accessed directly via a "remove" link, not through the normal flow,
    # so there's no incoming edge defined in the graph
    it "has no previous step" do
      expect(wizard).to have_previous_step(nil)
    end
  end

  context "from consider_pending_a_level" do
    let(:current_step) { :consider_pending_a_level }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    it "returns to add_a_level_to_a_list" do
      expect(wizard).to have_previous_step(:add_a_level_to_a_list)
    end
  end

  context "from a_level_equivalencies" do
    let(:current_step) { :a_level_equivalencies }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    it "returns to consider_pending_a_level" do
      expect(wizard).to have_previous_step(:consider_pending_a_level)
    end
  end

  context "from course_edit" do
    let(:current_step) { :course_edit }
    let(:a_level_subject_requirements) do
      [{ "uuid" => "123", "subject" => "maths", "minimum_grade_required" => "A" }]
    end

    it "returns to a_level_equivalencies" do
      expect(wizard).to have_previous_step(:a_level_equivalencies)
    end
  end
end
