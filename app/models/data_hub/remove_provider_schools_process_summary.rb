module DataHub
  class RemoveProviderSchoolsProcessSummary < ProcessSummary
    jsonb_accessor :short_summary,
                   removed_count: :integer,
                   skipped_with_courses_count: :integer,
                   kept_present_count: :integer,
                   kept_missing_count: :integer,
                   error: :string

    jsonb_accessor :full_summary,
                   removed: [:jsonb, { array: true, default: [] }],
                   skipped_with_courses: [:jsonb, { array: true, default: [] }],
                   kept_present: [:string, { array: true, default: [] }],
                   kept_missing: [:string, { array: true, default: [] }]
  end
end
