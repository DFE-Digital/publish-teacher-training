# frozen_string_literal: true

module Sites
  module Deduplication
    class TaskRunner
      def initialize(dry_run:, args:, logger: default_logger)
        @dry_run = dry_run
        @args = args
        @logger = logger
      end

      def call
        logger.tagged("sites:deduplicate") do
          logger.info("Starting #{dry_run ? 'dry run' : 'live run'} site deduplication...")

          provider_scope = build_provider_scope

          if provider_scope.none?
            puts "No providers matched the supplied filters. Nothing to do."
            next
          end

          site_scope = Site.where(provider_id: provider_scope.select(:id))

          site_count = site_scope.count
          provider_count = provider_scope.distinct.count

          logger.info("Processing #{site_count} site records across #{provider_count} provider(s).")

          process_summary = DataHub::Sites::Deduplication::Executor.new(
            site_scope:,
            dry_run:,
          ).execute

          print_summary(process_summary)
        end
      end

    private

      attr_reader :dry_run, :args, :logger

      def build_provider_scope
        provider_ids = parse_env_list(ENV["PROVIDER_IDS"]).map(&:to_i)
        provider_ids << args[:provider_id].to_i if args[:provider_id].present?
        provider_ids.reject!(&:zero?)

        if provider_ids.empty?
          raise ArgumentError, "You must supply at least one provider ID via PROVIDER_IDS or the task argument."
        end

        Provider.where(id: provider_ids)
      end

      def print_summary(process_summary)
        puts "Site deduplication recorded in process summary ##{process_summary.id}:"
        puts "- dry run: #{process_summary.dry_run}"
        puts "- duplicate groups processed: #{process_summary.duplicate_groups_processed}"
        puts "- duplicate sites discarded: #{process_summary.duplicate_sites_discarded}"
        puts "- site statuses reassigned: #{process_summary.site_statuses_reassigned}"
        puts "- site statuses merged: #{process_summary.site_statuses_merged}"
        puts "- redundant site statuses removed: #{process_summary.site_statuses_removed}"
      end

      def parse_env_list(raw)
        raw.to_s.split(",").map(&:strip).reject(&:blank?)
      end

      def default_logger
        ActiveSupport::TaggedLogging.new(Logger.new($stdout))
      end
    end
  end
end
