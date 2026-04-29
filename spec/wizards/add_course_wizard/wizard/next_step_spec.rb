# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard#next_step", type: :wizard do
  include_context "add_course_wizard"

  context "from level" do
    let(:current_step) { :level }

    context "when primary is selected" do
      let(:current_step_params) { { level: "primary", is_send: "false" } }

      it "proceeds to primary subjects" do
        expect(wizard).to have_next_step(:primary_subjects)
      end
    end

    context "when secondary is selected" do
      let(:current_step_params) { { level: "secondary", is_send: "false" } }

      it "proceeds to secondary subjects" do
        expect(wizard).to have_next_step(:secondary_subjects)
      end
    end

    context "when further education is selected" do
      let(:current_step_params) { { level: "further_education", is_send: "false" } }

      it "proceeds to courses page" do
        expect(wizard).to have_next_step(:courses_index)
      end
    end
  end

  context "from primary subjects" do
    let(:current_step) { :primary_subjects }

    it "proceeds to courses page" do
      expect(wizard).to have_next_step(:courses_index)
    end
  end

  context "from secondary subjects" do
    let(:current_step) { :secondary_subjects }

    it "proceeds to courses page" do
      expect(wizard).to have_next_step(:courses_index)
    end
  end
end
