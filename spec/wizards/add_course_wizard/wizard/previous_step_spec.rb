# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard#previous_step", type: :wizard do
  include_context "add_course_wizard"

  context "from level" do
    let(:current_step) { :level }

    it "has no previous step" do
      expect(wizard).to have_previous_step(nil)
    end
  end

  context "from primary subjects" do
    let(:current_step) { :primary_subjects }

    before do
      state_store.write(level: "primary")
    end

    it "goes back to level" do
      expect(wizard).to have_previous_step(:level)
    end
  end

  context "from secondary subjects" do
    let(:current_step) { :secondary_subjects }

    it "goes back to level" do
      expect(wizard).to have_previous_step(:level)
    end
  end
end
