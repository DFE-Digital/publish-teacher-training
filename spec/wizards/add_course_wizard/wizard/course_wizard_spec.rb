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

  describe "#clear_off_path_answers" do
    let(:current_step) { :secondary_subjects }

    before do
      state_store.write(
        level: "secondary",
        is_send: "false",
        secondary_master_subject_id: find_or_create(:secondary_subject, :physics).id.to_s,
        campaign_name: "engineers_teach_physics",
        age_range_in_years: "11_to_16",
        qualification: "qts",
        funding_type: "fee",
        study_pattern: %w[full_time],
        school_uuids: [create(:provider_school, provider:).uuid],
        study_sites_ids: [],
        can_sponsor_student_visa: true,
        visa_sponsorship_application_deadline_required: true,
        visa_sponsorship_application_deadline_at: { "year" => "2026", "month" => "9", "day" => "1" },
        start_date: "September 2026",
      )
    end

    it "keeps every answer on the path" do
      expect(wizard.clear_off_path_answers).to be_empty
      expect(state_store.campaign_name).to eq("engineers_teach_physics")
    end

    it "clears the specialism answers of subjects no longer chosen" do
      state_store.write(
        secondary_master_subject_id: find_or_create(:secondary_subject, :business_studies).id.to_s,
        language_ids: [find_or_create(:secondary_subject, :french).id.to_s],
        design_technology_ids: [find_or_create(:secondary_subject, :design_and_technology).id.to_s],
      )

      expect(wizard.clear_off_path_answers).to contain_exactly(
        :physics_specialisms, :modern_languages_specialisms, :design_technology_specialisms
      )
      expect(state_store.campaign_name).to be_nil
      expect(state_store.language_ids).to be_nil
      expect(state_store.design_technology_ids).to be_nil
    end

    it "clears the student visa answers when the funding becomes salary" do
      state_store.write(funding_type: "salary")

      wizard.clear_off_path_answers

      expect(state_store.can_sponsor_student_visa).to be_nil
      expect(state_store.visa_sponsorship_application_deadline_required).to be_nil
      expect(state_store.visa_sponsorship_application_deadline_at).to be_nil
      expect(state_store.funding_type).to eq("salary")
    end

    it "clears the funding, study pattern and visa answers when the qualification becomes TDA" do
      state_store.write(qualification: "undergraduate_degree_with_qts")

      wizard.clear_off_path_answers

      expect(state_store.funding_type).to be_nil
      expect(state_store.study_pattern).to be_nil
      expect(state_store.can_sponsor_student_visa).to be_nil
      expect(state_store.start_date).to eq("September 2026")
    end
  end
end
