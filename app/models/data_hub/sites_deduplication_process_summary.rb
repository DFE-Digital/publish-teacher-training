# frozen_string_literal: true

module DataHub
  # Stores aggregate metrics produced by site deduplication runs.
  class SitesDeduplicationProcessSummary < ProcessSummary
    jsonb_accessor :short_summary,
                   dry_run: :boolean,
                   duplicate_groups_processed: :integer,
                   duplicate_sites_discarded: :integer,
                   site_statuses_reassigned: :integer,
                   site_statuses_merged: :integer,
                   site_statuses_removed: :integer,
                   study_site_placements_reassigned: :integer,
                   study_site_placements_removed: :integer

    jsonb_accessor :full_summary,
                   deduplicated_groups: [:jsonb, { array: true, default: [] }]
  end
end
