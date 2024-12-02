# frozen_string_literal: true

require 'rails_helper'

describe 'GET /reporting' do
  let(:expected) do
    {
      providers: {
        total: {
          all: 0,
          non_training_providers: 0,
          training_providers: 0
        },
        training_providers: {
          findable_total: {
            open: 0,
            closed: 0
          },
          accredited_provider: {
            open: {
              accredited_provider: 0,
              not_an_accredited_provider: 0
            },
            closed: {
              accredited_provider: 0,
              not_an_accredited_provider: 0
            }
          },
          provider_type: {
            open: {
              scitt: 0,
              lead_partner: 0,
              university: 0
            },
            closed: {
              scitt: 0,
              lead_partner: 0,
              university: 0
            }
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
              scotland: 0
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
              scotland: 0
            }
          }
        }
      },
      courses: {
        total: {
          all: 0,
          non_findable: 0,
          all_findable: 0
        },
        findable_total: {
          open: 0,
          closed: 0
        },
        provider_type: {
          open: {
            scitt: 0, lead_partner: 0, university: 0
          },
          closed: {
            scitt: 0, lead_partner: 0, university: 0
          }
        },
        program_type: {
          open: {
            higher_education_programme: 0, higher_education_salaried_programme: 0,
            school_direct_training_programme: 0, school_direct_salaried_training_programme: 0, scitt_programme: 0,
            scitt_salaried_programme: 0, pg_teaching_apprenticeship: 0, teacher_degree_apprenticeship: 0
          },
          closed: {
            higher_education_programme: 0, higher_education_salaried_programme: 0,
            school_direct_training_programme: 0, school_direct_salaried_training_programme: 0, scitt_programme: 0,
            scitt_salaried_programme: 0, pg_teaching_apprenticeship: 0, teacher_degree_apprenticeship: 0
          }
        },
        study_mode: {
          open: { full_time: 0, part_time: 0, full_time_or_part_time: 0 },
          closed: { full_time: 0, part_time: 0, full_time_or_part_time: 0 }
        },
        qualification: {
          open: {
            qts: 0, pgce_with_qts: 0, pgde_with_qts: 0, pgce: 0, pgde: 0, undergraduate_degree_with_qts: 0
          },
          closed: {
            qts: 0, pgce_with_qts: 0, pgde_with_qts: 0, pgce: 0, pgde: 0, undergraduate_degree_with_qts: 0
          }
        },
        is_send: {
          open: { yes: 0, no: 0 },
          closed: { yes: 0, no: 0 }
        },
        subject: {
          open: Subject.active.each_with_index.map do |sub, _i|
                  x = {}
                  x[sub.subject_name] = 0
                  x
                end.reduce({}, :merge),
          closed: Subject.active.each_with_index.map do |sub, _i|
                    x = {}
                    x[sub.subject_name] = 0
                    x
                  end.reduce({}, :merge)
        }
      },
      publish: {
        users: {
          total: {
            all: 0,
            active_users: 0,
            non_active_users: 0
          },
          recent_active_users: 0
        },
        providers: {
          total: {
            all: 0,
            providers_with_non_active_users: 0,
            providers_with_recent_active_users: 0
          },
          with_1_recent_active_users: 0,
          with_2_recent_active_users: 0,
          with_3_recent_active_users: 0,
          with_4_recent_active_users: 0,
          with_more_than_5_recent_active_users: 0
        },
        courses: {
          total_updated_recently: 0,
          updated_non_findable_recently: 0,
          updated_findable_recently: 0,
          updated_open_courses_recently: 0,
          updated_closed_courses_recently: 0,
          created_recently: 0
        }
      },
      rollover: {
        total: {
          published_courses: 0,
          new_courses_published: 0,
          deleted_courses: 0,
          existing_courses_in_draft: 0,
          existing_courses_in_review: 0
        }
      }
    }.with_indifferent_access
  end

  let(:recruitment_cycle) do
    find_or_create(:recruitment_cycle)
  end

  let(:previous_recruitment_cycle) do
    find_or_create(:recruitment_cycle, :previous)
  end

  it 'returns status success' do
    recruitment_cycle
    previous_recruitment_cycle
    get '/reporting'
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(expected)
  end
end
