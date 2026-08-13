# frozen_string_literal: true

module DataHub
  # Stores what a duplicate schools classification run found. Nothing is
  # changed by the run, so this is the whole of its output: the counts a merge
  # policy gets chosen from, and the evidence behind them.
  #
  # Kinds and flags are tallies rather than a field per kind, so the list in
  # DataHub::DuplicateSchools::Kind stays the single source of truth and a fifth
  # shape needs no migration.
  class DuplicateSchoolsProcessSummary < ProcessSummary
    jsonb_accessor :short_summary,
                   years: [:string, { array: true, default: [] }],
                   groups_processed: :integer,
                   surplus_sites: :integer,
                   surplus_provider_schools: :integer,
                   kinds: [:jsonb, { array: true, default: [] }],
                   flags: [:jsonb, { array: true, default: [] }]

    jsonb_accessor :full_summary,
                   duplicate_groups: [:jsonb, { array: true, default: [] }]
  end
end
