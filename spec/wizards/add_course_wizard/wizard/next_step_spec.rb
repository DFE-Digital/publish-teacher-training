# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard#next_step", type: :wizard do
  include_context "add_course_wizard"

  context "from level" do
    let(:current_step) { :level }

    it "proceeds to subjects" do
      expect(wizard).to have_next_step(:subjects)
    end
  end

  context "from subjects" do
    let(:current_step) { :subjects }

    it "proceeds to courses page (for now)" do
      expect(wizard).to have_next_step(:courses_index)
    end
  end
end
