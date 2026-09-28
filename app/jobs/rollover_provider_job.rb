# frozen_string_literal: true

class RolloverProviderJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :low_priority
  without_auto_retry

  def perform(provider_code, recruitment_cycle_id, process_summary_id)
    DataHub::Rollover::ProviderProcessor.process(provider_code, recruitment_cycle_id, process_summary_id)
  end
end
