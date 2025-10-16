# frozen_string_literal: true

module DataHub
  module Sites
    module Deduplication
      # Coordinates deduplication runs and records results into the process summary table.
      class Executor
        # @param site_scope [ActiveRecord::Relation<Site>] scope of sites to consider
        # @param dry_run [Boolean] whether the deduplication should avoid mutating data
        def initialize(site_scope:, dry_run:)
          @site_scope = site_scope
          @dry_run = dry_run
        end

        # Executes the deduplication workflow and records a process summary.
        #
        # @return [DataHub::SitesDeduplicationProcessSummary]
        def execute
          process_summary = DataHub::SitesDeduplicationProcessSummary.start!

          outcome = Deduplicator.new(site_scope:, dry_run:).call
          summary_builder = SummaryBuilder.new(outcome)

          process_summary.finish!(
            short_summary: summary_builder.short_summary,
            full_summary: summary_builder.full_summary,
          )

          process_summary
        rescue StandardError => e
          process_summary&.fail!(e)
          raise e
        end

      private

        attr_reader :site_scope, :dry_run
      end
    end
  end
end
