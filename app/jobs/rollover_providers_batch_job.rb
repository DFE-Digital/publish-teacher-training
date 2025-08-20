class RolloverProvidersBatchJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 0

  def perform(provider_codes, recruitment_cycle_id, summary_id)
    summary = DataHub::RolloverProcessSummary.find(summary_id)

    provider_codes.each do |provider_code|
      RolloverProviderJob.perform_async(provider_code, recruitment_cycle_id, summary_id)
    end

    summary.add_batch_enqueue_result(provider_codes:)
  end
end
