# frozen_string_literal: true

module DataHub
  module Rollover
    class JobOrchestrator
      BATCH_SIZE = 5
      STAGGER_OVER = 2.hours
      MONITORING_DELAY = 5.minutes

      def self.start_rollover(recruitment_cycle_id)
        new(recruitment_cycle_id).execute
      end

      def initialize(recruitment_cycle_id)
        @recruitment_cycle_id = recruitment_cycle_id
        @process_summary = nil
      end

      def execute
        initialize_process_summary
        schedule_provider_jobs
        schedule_monitoring

        Rails.logger.info "Rollover orchestration complete. " \
                          "#{@process_summary.short_summary['total_providers']} providers scheduled"

        @process_summary
      rescue StandardError => e
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
          providers.pluck(:provider_code).each do |provider_code|
            RolloverProviderJob.perform_at(
              batch_time,
              provider_code,
              recruitment_cycle_id,
              @process_summary.id,
            )
          end
        end
      end

      def schedule_monitoring
        monitoring_start_time = STAGGER_OVER + MONITORING_DELAY
        attempt_number = 1

        RolloverMonitoringJob.perform_in(
          monitoring_start_time,
          @process_summary.id,
          attempt_number,
        )

        Rails.logger.info "Scheduled monitoring to start in #{monitoring_start_time.to_i / 60} minutes"
      end

      def current_providers
        @current_providers ||= RecruitmentCycle.current_recruitment_cycle.providers
      end
    end
  end
end
