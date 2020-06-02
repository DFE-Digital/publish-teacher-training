require "rails_helper"

describe "GET /reporting" do
  let(:expected) do
    {
      providers: {
        total: {
          all: 0,
          non_findable: 0,
          all_findable: 0,
        },
        findable_total: {
          open: 0,
          closed: 0,
        },
        accredited_body: {
          open: {
            accredited_body: 0,
            not_an_accredited_body: 0,
          },
          closed: {
            accredited_body: 0,
            not_an_accredited_body: 0,
          },
        },
        provider_type: {
          open: {
            scitt: 0,
            lead_school: 0,
            university: 0,
            unknown: 0,
            invalid_value: 0,
          },
          closed: {
            scitt: 0,
            lead_school: 0,
            university: 0,
            unknown: 0,
            invalid_value: 0,
          },
        },
        region_code: {
          open: {
            no_region: 0,
            london: 0,
            south_east: 0,
            south_west: 0,
            wales: 0,
            west_midlands: 0,
            east_midlands: 0,
            eastern: 0,
            north_west: 0,
            yorkshire_and_the_humber: 0,
            north_east: 0,
            scotland: 0,
          },
          closed: {
            no_region: 0,
            london: 0,
            south_east: 0,
            south_west: 0,
            wales: 0,
            west_midlands: 0,
            east_midlands: 0,
            eastern: 0,
            north_west: 0,
            yorkshire_and_the_humber: 0,
            north_east: 0,
            scotland: 0,
          },
        },
      },
      courses: {
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
          closed: { yes: 0, no: 0 },
        },
        subject: {
          open: Subject.active.each_with_index.map { |sub, _i| x = {}; x[sub.subject_name] = 0; x }.reduce({}, :merge),
          closed: Subject.active.each_with_index.map { |sub, _i| x = {}; x[sub.subject_name] = 0; x }.reduce({}, :merge),
        },
      },
      publish: {
        users: {
          total: {
            all: 0,
            active_users: 0,
            non_active_users: 0,
          },
          recent_active_users: 0,
        },
        providers: {
          total: {
            all: 0,
            providers_with_non_active_users: 0,
            providers_with_recent_active_users: 0,
          },
          with_1_recent_active_users: 0,
          with_2_recent_active_users: 0,
          with_3_recent_active_users: 0,
          with_4_recent_active_users: 0,
          with_more_than_5_recent_active_users: 0,
        },
        courses: {
          total_updated_recently: 0,
          updated_non_findable_recently: 0,
          updated_findable_recently: 0,
          updated_open_courses_recently: 0,
          updated_closed_courses_recently: 0,
          created_recently: 0,
        },

        allocation: {
          previous: {
            total: {
              allocations: 0,
              distinct_accredited_bodies: 0,
              distinct_providers: 0,
              number_of_places:  0,
            },
          },
          current: {
            total: {
              allocations: 0,
              distinct_accredited_bodies: 0,
              distinct_providers: 0,
              number_of_places:  0,
            },
          },
        },
      },
    }.with_indifferent_access
  end

  let(:previous_recruitment_cycle) {
    find_or_create(:recruitment_cycle, :previous)
  }

  it "returns status success" do
    previous_recruitment_cycle
    get "/reporting"
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq(expected)
  end
end
