# frozen_string_literal: true

module DataHub
  module Rollover
    class JobOrchestrator
      BATCH_SIZE = 5
      STAGGER_OVER = 2.hours
      MONITORING_DELAY = 5.minutes
      MONITORING_START_TIME = STAGGER_OVER + MONITORING_DELAY

      attr_reader :recruitment_cycle_id

      def self.start_rollover(recruitment_cycle_id)
        new(recruitment_cycle_id).execute
      end

      def self.total_rollover_duration
        stagger_seconds = STAGGER_OVER.to_i
        monitoring_seconds = MonitoringManager::MAX_ATTEMPTS * MonitoringManager::CHECK_INTERVAL.to_i
        total_seconds = stagger_seconds + monitoring_seconds

        hours = total_seconds / 3600
        minutes = (total_seconds % 3600) / 60

        "#{hours}h #{minutes}m"
      end

      def initialize(recruitment_cycle_id)
        @recruitment_cycle_id = recruitment_cycle_id
      end

      def execute
        RolloverLog.with_logging do
          initialize_process_summary
          schedule_provider_jobs
          schedule_monitoring

          RolloverLog.info("Orchestration complete: #{@process_summary.short_summary['total_providers']} scheduled")
        end
        @process_summary
      rescue StandardError => e
        RolloverLog.error("Orchestration failed: #{e.message}")
        @process_summary&.fail!(e)
        raise
      end

    private

      def initialize_process_summary
        @process_summary = RolloverProcessSummary.start!
        @process_summary.initialize_summary!

        total_providers = current_providers.count
        @process_summary.set_total_providers(total_providers)
      end

      def schedule_provider_jobs
        scheduled_codes = schedule_initial_batches
        missing_codes = identify_missing_providers(scheduled_codes)
        schedule_missing_providers(missing_codes) if missing_codes.any?
      end

      def schedule_initial_batches
        scheduled_codes = Set.new

        BatchDelivery.new(
          relation: current_providers,
          stagger_over: STAGGER_OVER,
          batch_size: BATCH_SIZE,
        ).each do |batch_time, providers|
          provider_codes = providers.map(&:provider_code)
          scheduled_codes.merge(provider_codes)

          RolloverProvidersBatchJob
            .set(wait_until: batch_time)
            .perform_later(
              provider_codes,
              @recruitment_cycle_id,
              @process_summary.id,
            )
        end

        scheduled_codes
      end

      def identify_missing_providers(scheduled_codes)
        all_provider_codes = current_providers.pluck(:provider_code).to_set

        all_provider_codes - scheduled_codes
      end

      def schedule_missing_providers(missing_codes)
        @process_summary.add_missing_batch(missing_codes)

        RolloverProvidersBatchJob
          .set(wait_until: STAGGER_OVER.from_now + 1.minute)
          .perform_later(
            missing_codes.to_a,
            @recruitment_cycle_id,
            @process_summary.id,
          )
      end

      def schedule_monitoring
        attempt_number = 1

        RolloverMonitoringJob.perform_in(
          MONITORING_START_TIME,
          @process_summary.id,
          attempt_number,
        )

        RolloverLog.info("Scheduled monitoring to start in #{MONITORING_START_TIME.to_i / 60} minutes")
      end

      def current_providers
        @current_providers ||= RecruitmentCycle.current_recruitment_cycle.providers.order(:id)
      end
    end
  end
end
