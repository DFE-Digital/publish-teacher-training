# frozen_string_literal: true

module DataHub
  module Rollover
    class ProviderProcessor
      def self.process(provider_code, recruitment_cycle_id, process_summary_id)
        new(provider_code, recruitment_cycle_id, process_summary_id).execute
      end

      def initialize(provider_code, recruitment_cycle_id, process_summary_id)
        @provider_code = provider_code
        @recruitment_cycle_id = recruitment_cycle_id
        @process_summary_id = process_summary_id
        @process_summary = nil
      end

      def execute
        load_process_summary

        begin
          result = perform_rollover
          record_success(result)
        rescue StandardError => e
          record_error(e)
        end
      end

    private

      attr_reader :provider_code, :recruitment_cycle_id, :process_summary_id, :process_summary

      def load_process_summary
        @process_summary = RolloverProcessSummary.find(process_summary_id)
      end

      def perform_rollover
        result = RolloverProviderService.call(
          provider_code: provider_code,
          new_recruitment_cycle_id: recruitment_cycle_id,
          force: false,
        )

        Rails.logger.info "Rollover result for #{provider_code}: #{result.inspect}"
        result
      end

      def record_success(result)
        if provider_was_rolled_over?(result)
          record_rollover_success(result)
        else
          record_skip
        end
      end

      def provider_was_rolled_over?(result)
        result[:providers].positive?
      end

      def record_rollover_success(result)
        process_summary.add_provider_result(
          provider_code:,
          status: :rolled_over,
          details: {
            courses_count: result[:courses],
            sites_count: result[:sites],
            study_sites_count: result[:study_sites],
            partnerships_count: result[:partnerships],
            courses_skipped: result[:courses_skipped] || [],
            courses_failed: result[:courses_failed] || [],
          },
        )

        Rails.logger.info "Successfully rolled over provider #{provider_code}"
      end

      def record_skip
        process_summary.add_provider_result(
          provider_code: provider_code,
          status: :skipped,
          details: {
            reason: "Provider not rollable or already exists in target cycle",
          },
        )

        Rails.logger.info "Skipped provider #{provider_code} - not rollable or already exists"
      end

      def record_error(error)
        process_summary.add_provider_result(
          provider_code:,
          status: :errored,
          details: {
            error_class: error.class.to_s,
            error_message: error.message,
            backtrace: error.backtrace&.take(10),
          },
        )

        # Don't re-raise - we want to continue with other providers
        Rails.logger.error "Failed to rollover provider #{provider_code}: #{error.message}"
      end
    end
  end
end
