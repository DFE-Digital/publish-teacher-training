class RolloverProvidersBatchJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :low_priority
  without_auto_retry

  def perform(provider_codes, recruitment_cycle_id, summary_id)
    summary = DataHub::RolloverProcessSummary.find(summary_id)

    provider_codes.each do |provider_code|
      RolloverProviderJob.perform_later(provider_code, recruitment_cycle_id, summary_id)
    end

    summary.add_batch_enqueue_result(provider_codes:)
  end
end
