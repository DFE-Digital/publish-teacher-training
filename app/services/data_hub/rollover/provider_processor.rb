# frozen_string_literal: true

module DataHub
  module Rollover
    class ProviderProcessor
      def self.process(provider_code, recruitment_cycle_id, process_summary_id)
        new(provider_code, recruitment_cycle_id, process_summary_id).process
      end

      def initialize(provider_code, recruitment_cycle_id, process_summary_id)
        @provider_code = provider_code
        @recruitment_cycle_id = recruitment_cycle_id
        @process_summary_id = process_summary_id
      end

      def process
        process_provider_rollover
      rescue StandardError => e
        record_fatal_error(e)
      end

    private

      attr_reader :provider_code, :recruitment_cycle_id, :process_summary_id

      def process_provider_rollover
        result = perform_rollover
        record_rollover_result(result)
      end

      def perform_rollover
        RolloverProviderService.call(
          provider_code: provider_code,
          new_recruitment_cycle_id: recruitment_cycle_id,
          force: false,
        )
      end

      def record_rollover_result(result)
        if provider_rolled_over?(result)
          add_provider_result(:rolled_over, result)
        else
          add_provider_result(:skipped, result.merge(reason: "Provider not rollable or already exists in target cycle"))
        end
      end

      def provider_rolled_over?(result)
        result[:providers].to_i.positive?
      end

      def add_provider_result(status, details)
        process_summary.add_provider_result(
          provider_code: provider_code,
          status: status,
          details: provider_details(details),
        )
      end

      def provider_details(result)
        {
          courses_count: result[:courses],
          sites_count: result[:sites],
          study_sites_count: result[:study_sites],
          partnerships_count: result[:partnerships],
          courses_failed: result[:courses_failed] || [],
          courses_skipped: result[:courses_skipped] || [],
          study_sites_skipped: result[:study_sites_skipped] || [],
          duration_seconds: result[:duration_seconds],
        }.compact.merge(reason: result[:reason]).compact
      end

      def process_summary
        @process_summary ||= RolloverProcessSummary.find(process_summary_id)
      end

      def record_fatal_error(error)
        process_summary.add_provider_result(
          provider_code: provider_code,
          status: :errored,
          details: error_details(error),
        )
      end

      def error_details(error)
        {
          error_class: error.class.to_s,
          error_message: error.message,
          backtrace: error.backtrace&.take(10),
        }
      end
    end
  end
end
