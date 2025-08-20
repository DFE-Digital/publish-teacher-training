# frozen_string_literal: true

module DataHub
  class RolloverProcessSummary < ProcessSummary
    def initialize_summary!
      update!(
        short_summary: default_short_summary,
        full_summary: default_full_summary,
      )
    end

    def set_total_providers(count)
      with_lock do
        current_short = short_summary.dup
        current_short["total_providers"] = count
        update!(short_summary: current_short)
      end
    end

    def add_provider_result(provider_code:, status:, details: {})
      with_lock do
        current_short = short_summary.dup
        current_full = full_summary.dup

        update_counters(current_short, status, details)
        add_error_if_needed(current_full, provider_code, status, details)
        add_provider_info(current_full, provider_code, status, details)

        update!(
          short_summary: current_short,
          full_summary: current_full,
        )
      end
    end

    def total_processed
      short_summary["providers_rolled_over"] +
        short_summary["providers_skipped"] +
        short_summary["providers_errored"]
    end

    def completion_percentage
      return 0 if short_summary["total_providers"].zero?

      (total_processed.to_f / short_summary["total_providers"] * 100).round(2)
    end

  private

    def default_short_summary
      {
        total_providers: 0,
        providers_rolled_over: 0,
        providers_skipped: 0,
        providers_errored: 0,
        total_courses_rolled_over: 0,
        total_sites_rolled_over: 0,
        total_study_sites_rolled_over: 0,
        total_partnerships_rolled_over: 0,
      }
    end

    def default_full_summary
      {
        providers_processed: [],
        errors: [],
        rollover_started_at: Time.current.iso8601,
      }
    end

    def update_counters(current_short, status, details)
      case status
      when :rolled_over
        current_short["providers_rolled_over"] += 1
        current_short["total_courses_rolled_over"] += details[:courses_count] || 0
        current_short["total_sites_rolled_over"] += details[:sites_count] || 0
        current_short["total_study_sites_rolled_over"] += details[:study_sites_count] || 0
        current_short["total_partnerships_rolled_over"] += details[:partnerships_count] || 0
      when :skipped
        current_short["providers_skipped"] += 1
      when :errored
        current_short["providers_errored"] += 1
      end
    end

    def add_error_if_needed(current_full, provider_code, status, details)
      return unless status == :errored

      current_full["errors"] << {
        provider_code: provider_code,
        error_class: details[:error_class],
        error_message: details[:error_message],
        timestamp: Time.current.iso8601,
      }
    end

    def add_provider_info(current_full, provider_code, status, details)
      provider_info = {
        provider_code: provider_code,
        status: status,
        timestamp: Time.current.iso8601,
      }.merge(details)
      current_full["providers_processed"] << provider_info
    end
  end
end
