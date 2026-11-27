# frozen_string_literal: true

require "rails_helper"

# The course's answers (their defaults and combined values) are covered by the
# state store spec. This covers the keys the course creation service takes.
RSpec.describe Courses::WizardParamsSerializer, type: :wizard do
  subject(:params) { described_class.call(wizard:) }

  include_context "add_course_wizard"

  let(:school_uuids) { %w[11111111-1111-4111-8111-111111111111 22222222-2222-4222-8222-222222222222] }

  before do
    state_store.write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: "100",
      subordinate_subject_id: "200",
      age_range_in_years: "other",
      course_age_range_in_years_other_from: "14",
      course_age_range_in_years_other_to: "19",
      qualification: "pgce_with_qts",
      funding_type: "salary",
      study_pattern: %w[full_time part_time],
      school_uuids: [*school_uuids, ""],
      study_sites_ids: %w[3],
      accredited_provider_code: "A0A",
      start_date: "July 2027",
      campaign_name: "no_campaign",
      can_sponsor_student_visa: false,
      can_sponsor_skilled_worker_visa: true,
      visa_sponsorship_application_deadline_required: true,
      visa_sponsorship_application_deadline_at: Date.new(2027, 3, 1),
    )
  end

  it "maps the answers to the keys of the course creation service" do
    expect(params.to_h).to include(
      "level" => "secondary",
      "is_send" => "false",
      "master_subject_id" => "100",
      "subordinate_subject_id" => "200",
      "subjects_ids" => %w[100 200],
      "age_range_in_years" => "14_to_19",
      "qualification" => "pgce_with_qts",
      "funding" => "salary",
      "study_mode" => %w[full_time part_time],
      "school_uuids" => school_uuids,
      "study_sites_ids" => %w[3],
      "accredited_provider_code" => "A0A",
      "start_date" => "July 2027",
      "campaign_name" => "no_campaign",
      "can_sponsor_student_visa" => false,
      "can_sponsor_skilled_worker_visa" => true,
      "visa_sponsorship_application_deadline_required" => true,
      "visa_sponsorship_application_deadline_at(1i)" => "2027",
      "visa_sponsorship_application_deadline_at(2i)" => "3",
      "visa_sponsorship_application_deadline_at(3i)" => "1",
    )
    expect(params).not_to have_key("visa_sponsorship_application_deadline_at")
  end

  it "takes the defaults of a TDA course" do
    state_store.write(qualification: "undergraduate_degree_with_qts", funding_type: nil, study_pattern: nil, can_sponsor_skilled_worker_visa: nil)

    expect(params.to_h).to include("funding" => "apprenticeship", "study_mode" => %w[full_time], "can_sponsor_skilled_worker_visa" => false)
  end

  it "leaves out the study sites when the question was not answered" do
    state_store.write(study_sites_ids: nil)

    expect(params).not_to have_key("study_sites_ids")
  end

  it "leaves out a visa deadline that is missing or incomplete" do
    state_store.write(visa_sponsorship_application_deadline_at: { year: "2028", month: nil, day: "2" })
    expect(params.keys.grep(/visa_sponsorship_application_deadline_at/)).to be_empty

    state_store.write(visa_sponsorship_application_deadline_at: nil)
    expect(params.keys.grep(/visa_sponsorship_application_deadline_at/)).to be_empty
  end
end
