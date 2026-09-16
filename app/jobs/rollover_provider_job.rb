# frozen_string_literal: true

class RolloverProviderJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 0

  def perform(provider_code, recruitment_cycle_id, process_summary_id)
    DataHub::Rollover::ProviderProcessor.process(provider_code, recruitment_cycle_id, process_summary_id)
  end
end
