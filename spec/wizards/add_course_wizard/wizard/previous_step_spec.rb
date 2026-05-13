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

  context "from age range with primary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(primary_master_subject_id: "123")
      state_store.write(level: "primary")
    end

    it "goes back to primary subjects" do
      expect(wizard).to have_previous_step(:primary_subjects)
    end
  end

  context "from age range with secondary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "secondary")
      state_store.write(secondary_master_subject_id: "123", subordinate_subject_id: "456")
    end

    it "goes back to secondary subjects" do
      expect(wizard).to have_previous_step(:secondary_subjects)
    end
  end

  context "from age range with secondary level when primary and secondary subjects are both present" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "secondary")
      state_store.write(primary_master_subject_id: "123")
      state_store.write(secondary_master_subject_id: "456", subordinate_subject_id: "789")
    end

    it "goes back to secondary subjects" do
      expect(wizard).to have_previous_step(:secondary_subjects)
    end
  end
end
