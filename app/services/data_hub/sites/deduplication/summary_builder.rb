# frozen_string_literal: true

module DataHub
  module Sites
    module Deduplication
      # Builds a short and full summary for a deduplication outcome ready for persistence.
      class SummaryBuilder
        def initialize(outcome)
          @outcome = outcome
        end

        # @return [Hash] counts of actions performed or planned
        def short_summary
          {
            dry_run: outcome.dry_run,
            duplicate_groups_processed: groups.count,
            duplicate_sites_discarded: groups.sum { |g| g.sites_discarded.count },
            site_statuses_reassigned: groups.sum { |g| g.site_status_reassignments.count },
            site_statuses_merged: groups.sum { |g| g.site_status_merges.count },
            site_statuses_removed: groups.sum { |g| g.site_status_removals.count },
          }
        end

        # @return [Hash] detailed per-group changes captured during the run
        def full_summary
          {
            deduplicated_groups: groups.map do |group|
              {
                primary_site_id: group.primary_site_id,
                duplicate_site_ids: group.duplicate_site_ids,
                sites_discarded: group.sites_discarded,
                site_status_reassignments: group.site_status_reassignments,
                site_status_merges: group.site_status_merges,
                site_status_removals: group.site_status_removals,
              }
            end,
          }
        end

      private

        attr_reader :outcome

        def groups
          outcome.groups
        end
      end
    end
  end
end
