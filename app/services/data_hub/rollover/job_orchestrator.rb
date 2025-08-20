# frozen_string_literal: true

module DataHub
  module Rollover
    class JobOrchestrator
      BATCH_SIZE = 5
      STAGGER_OVER = 2.hours
      MONITORING_DELAY = 5.minutes
      MONITORING_START_TIME = STAGGER_OVER + MONITORING_DELAY

      def self.start_rollover(recruitment_cycle_id)
        new(recruitment_cycle_id).execute
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

      attr_reader :recruitment_cycle_id

      def initialize_process_summary
        @process_summary = RolloverProcessSummary.start!
        @process_summary.initialize_summary!

        total_providers = current_providers.count
        @process_summary.set_total_providers(total_providers)
      end

      def schedule_provider_jobs
        BatchDelivery.new(
          relation: current_providers,
          stagger_over: STAGGER_OVER,
          batch_size: BATCH_SIZE,
        ).each do |batch_time, providers|
          RolloverProvidersBatchJob
            .set(wait_until: batch_time)
            .perform_later(
              providers.map(&:provider_code),
              @recruitment_cycle_id,
              @process_summary.id,
            )
        end
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
        @current_providers ||= RecruitmentCycle.current_recruitment_cycle.providers
      end
    end
  end
end
