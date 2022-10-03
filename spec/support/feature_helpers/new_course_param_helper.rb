# frozen_string_literal: true

module FeatureHelpers
  module NewCourseParam
    def accredited_body_params
      {
        "course[qualification]" => "qts",
        "course[funding_type]" => ["fee"],
        "course[level]" => "secondary",
        "course[is_send]" => ["0"],
        "course[study_mode]" => "full_time",
        "course[age_range_in_years]" => ["11_to_16"],
        "course[subjects_ids][]" => "2",
        "commit" => ["Continue"],
      }
    end

    def age_range_params
      {
        "course[is_send]" => ["0"],
        "course[level]" => "primary",
        "course[subjects_ids][]" => "2",
      }
    end

    def applications_open_from_params
      {
        "course[qualification]" => "qts",
        "course[funding_type]" => ["fee"],
        "course[level]" => "secondary",
        "course[is_send]" => ["0"],
        "course[study_mode]" => "full_time",
        "course[age_range_in_years]" => ["11_to_16"],
        "course[subjects_ids][]" => "2",
        "commit" => ["Continue"],
      }
    end

    def outcome_params
      {
        "course[is_send]" => ["0"],
        "course[level]" => "primary",
        "course[subjects_ids][]" => "2",
        "course[age_range_in_years]" => ["3_to_7"],
      }
    end

    def funding_type_params
      {
        "course[is_send]" => ["0"],
        "course[level]" => "primary",
        "course[subjects_ids][]" => "2",
        "course[age_range_in_years]" => ["3_to_7"],
      }
    end

    def locations_params
      {
        "course[age_range_in_years]" => ["3_to_7"],
        "course[funding_type]" => ["fee"],
        "course[is_send]" => ["0"],
        "course[level]" => "primary",
        "course[qualification]" => "qts",
        "course[study_mode]" => "full_time",
        "course[subjects_ids][]" => "2",
      }
    end

    def confirmation_params(provider)
      {
        "course[accredited_body_code]" => provider.courses.first.accrediting_provider.provider_code,
        "course[age_range_in_years]" => "14_to_19",
        "course[applications_open_from]" => "#{provider.recruitment_cycle_year.to_i - 1}-10-12",
        "course[funding_type]" => "apprenticeship",
        "course[is_send]" => "0",
        "course[level]" => "secondary",
        "course[qualification]" => "pgde_with_qts",
        "course[start_date]" => "October #{provider.recruitment_cycle_year.to_i - 1}",
        "course[study_mode]" => "full_time_or_part_time",
        "course[subjects_ids][]" => "30",
        "course[sites_ids][]" => provider.sites.first.id,
      }
    end

    def start_date_params(provider)
      {
        "course[qualification]" => "qts",
        "course[accredited_body_code]" => provider.courses.first.accrediting_provider.provider_code,
        "course[funding_type]" => ["fee"],
        "course[level]" => "secondary",
        "course[is_send]" => ["0"],
        "course[study_mode]" => "full_time",
        "course[age_range_in_years]" => ["11_to_16"],
        "course[subjects_ids][]" => "30",
        "course[applications_open_from]" => "2021-10-12",
      }
    end

    def study_mode_params
      {
        "course[is_send]" => ["0"],
        "course[level]" => "primary",
        "course[subjects_ids][]" => "2",
        "course[age_range_in_years]" => ["3_to_7"],
      }
    end

    def level_params(level)
      public_send("#{level}_subject_params")
    end

    def primary_subject_params
      { "course[is_send]" => ["0"], "course[level]" => "primary" }
    end

    def secondary_subject_params
      { "course[is_send]" => ["0"], "course[level]" => "secondary" }
    end
  end
end
