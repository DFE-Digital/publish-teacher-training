module DataHub
  class DiscardInvalidSchoolsProcessSummary < ProcessSummary
    jsonb_accessor :short_summary,
                   discarded_total_count: :integer,
                   discarded_lack_urn: :integer,
                   discarded_invalid_gias_urn: :integer,
                   error: :string

    jsonb_accessor :full_summary,
                   discarded_ids_lack_urn: [:integer, { array: true, default: [] }],
                   discarded_invalid_urns: [:jsonb, { array: true, default: [] }]
  end
end
