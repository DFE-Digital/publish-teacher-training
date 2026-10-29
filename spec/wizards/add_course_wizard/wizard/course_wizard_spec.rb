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

  describe "#invalid_steps" do
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

    it "returns no steps when every step on the path is valid" do
      expect(wizard.invalid_steps).to be_empty
    end

    it "returns a step the path now needs that was never answered" do
      state_store.write(can_sponsor_student_visa: true)

      expect(wizard.invalid_steps.map(&:step_id)).to eq(%i[visa_sponsorship_application_deadline_required])
    end

    it "returns every invalid step on the path in path order" do
      state_store.write(age_range_in_years: nil, can_sponsor_student_visa: true)

      expect(wizard.invalid_steps.map(&:step_id)).to eq(%i[age_range visa_sponsorship_application_deadline_required])
    end

    it "returns each invalid step holding its validation errors" do
      state_store.write(age_range_in_years: nil)

      expect(wizard.invalid_steps.first.errors.messages_for(:age_range_in_years)).to be_present
    end

    it "ignores an invalid answer on a step that is off the path" do
      state_store.write(primary_master_subject_id: nil, can_sponsor_skilled_worker_visa: nil)

      expect(wizard.invalid_steps).to be_empty
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

  describe "change journeys" do
    it "asks the visa questions again after a funding type change" do
      expect(wizard).to queue_after_change(:funding_type).units(:visa)
    end

    it "asks the funding, study pattern and visa questions again after a qualification change" do
      expect(wizard).to queue_after_change(:qualification).units(:funding_type, :study_pattern, :visa)
    end

    it "asks the specialism questions again after a subject change" do
      specialisms = %i[design_technology_specialisms physics_specialisms modern_languages_specialisms]

      expect(wizard).to queue_after_change(:secondary_master_subject_id).units(*specialisms)
      expect(wizard).to queue_after_change(:subordinate_subject_id).units(*specialisms)
    end

    it "asks no other question after a level change" do
      expect(wizard).to queue_after_change(:level).units
    end

    it "asks no other question after an age range change" do
      expect(wizard).to queue_after_change(:age_range_in_years).units
    end

    it "does not ask the visa questions again after a study pattern change" do
      expect(wizard).not_to queue_after_change(:study_pattern).units(:visa)
    end
  end
end
