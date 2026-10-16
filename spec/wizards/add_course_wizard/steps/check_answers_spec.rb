# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::CheckAnswers do
  include_context "add_course_wizard"

  let(:current_step) { :check_answers }
  let(:wizard_step) { wizard.current_step }

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

  describe "#valid?" do
    it "is valid when every question on the path is answered" do
      expect(wizard_step).to be_valid
    end

    it "adds the step's own error for each unanswered question" do
      state_store.write(start_date: nil)

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:start_date)).to contain_exactly("Select a course start date")
    end
  end
end
