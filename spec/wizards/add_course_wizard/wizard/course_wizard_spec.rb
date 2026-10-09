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

  describe "#first_invalid_step" do
    let(:current_step) { :check_answers }

    before do
      state_store.write(
        level: "secondary",
        is_send: "false",
        secondary_master_subject_id: find_or_create(:secondary_subject, :business_studies).id.to_s,
        age_range_in_years: "11_to_16",
        qualification: "qts",
        funding_type: "fee",
        study_pattern: %w[full_time],
        school_uuids: [create(:provider_school, provider:).uuid],
        study_sites_ids: [],
        can_sponsor_student_visa: false,
        start_date: "September 2026",
      )
    end

    it "returns nil when every step on the path is valid" do
      expect(wizard.first_invalid_step).to be_nil
    end

    it "returns a step the path now needs that was never answered" do
      state_store.write(can_sponsor_student_visa: true)

      expect(wizard.first_invalid_step).to eq(:visa_sponsorship_application_deadline_required)
    end

    it "returns the earliest invalid step on the path" do
      state_store.write(age_range_in_years: nil, can_sponsor_student_visa: true)

      expect(wizard.first_invalid_step).to eq(:age_range)
    end

    it "ignores an invalid answer on a step that is off the path" do
      state_store.write(primary_master_subject_id: nil, can_sponsor_skilled_worker_visa: nil)

      expect(wizard.first_invalid_step).to be_nil
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
