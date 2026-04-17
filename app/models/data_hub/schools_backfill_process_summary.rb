# frozen_string_literal: true

module DataHub
  class SchoolsBackfillProcessSummary < ProcessSummary
    jsonb_accessor :short_summary,
                   provider_schools_inserted: [:integer, { default: 0 }],
                   course_schools_inserted: [:integer, { default: 0 }],
                   sites_skipped: [:integer, { default: 0 }],
                   course_sites_skipped: [:integer, { default: 0 }]

    jsonb_accessor :full_summary,
                   skipped_sites_csv_path: :string,
                   skipped_course_sites_csv_path: :string
  end
end
