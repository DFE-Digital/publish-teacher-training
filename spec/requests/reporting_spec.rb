require "rails_helper"

describe "GET /reporting" do
  let(:expected) do
    {
      total: {
        all: 0,
        non_findable: 0,
        all_findable: 0,
      },
      findable_total: {
        open: 0,
        closed: 0,
      },
      provider_type: {
        open: {
          scitt: 0, lead_school: 0, university: 0, unknown: 0, invalid_value: 0
        },
        closed: {
          scitt: 0, lead_school: 0, university: 0, unknown: 0, invalid_value: 0
        },
      },
      program_type: {
        open: {
          higher_education_programme: 0, school_direct_training_programme: 0,
          school_direct_salaried_training_programme: 0, scitt_programme: 0,
          pg_teaching_apprenticeship: 0
        },
        closed: {
          higher_education_programme: 0, school_direct_training_programme: 0,
          school_direct_salaried_training_programme: 0, scitt_programme: 0,
          pg_teaching_apprenticeship: 0
        },
      },
      study_mode: {
        open: { full_time: 0, part_time: 0, full_time_or_part_time: 0 },
        closed: { full_time: 0, part_time: 0, full_time_or_part_time: 0 },
      },
      qualification: {
        open: {
          qts: 0, pgce_with_qts: 0, pgde_with_qts: 0, pgce: 0, pgde: 0
        },
        closed: {
          qts: 0, pgce_with_qts: 0, pgde_with_qts: 0, pgce: 0, pgde: 0
        },
      },
      is_send: {
        open: { yes: 0, no: 0 },
        closed:  { yes: 0, no: 0 },
      },
    }.with_indifferent_access
  end

  it "returns status success" do
    get "/reporting"
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq(expected)
  end
end
