# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard, type: :wizard do
  include_context "add_course_wizard"

  describe "#final_step?" do
    context "when current step is check answers" do
      let(:current_step) { :check_answers }

      it "returns true" do
        expect(wizard.final_step?).to be(true)
      end
    end

    context "when current step is not check answers" do
      let(:current_step) { :start_date }

      it "returns false" do
        expect(wizard.final_step?).to be(false)
      end
    end
  end

  describe "#clear_stale_specialism_answers" do
    let(:current_step) { :secondary_subjects }

    it "clears stale specialism values based on selected subjects" do
      state_store.write(
        level: "secondary",
        secondary_master_subject_id: find_or_create(:secondary_subject, :business_studies).id.to_s,
        subordinate_subject_id: find_or_create(:secondary_subject, :religious_education).id.to_s,
        campaign_name: "engineers_teach_physics",
        language_ids: [find_or_create(:secondary_subject, :french).id.to_s],
        design_technology_ids: [find_or_create(:secondary_subject, :design_and_technology).id.to_s],
      )

      wizard.clear_stale_specialism_answers

      expect(state_store.campaign_name).to be_nil
      expect(state_store.language_ids).to be_nil
      expect(state_store.design_technology_ids).to be_nil
    end
  end
end
