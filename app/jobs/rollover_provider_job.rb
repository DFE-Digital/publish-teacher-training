# frozen_string_literal: true

class RolloverProviderJob
  include Sidekiq::Job

  sidekiq_options retry: false

  def perform(provider_code, recruitment_cycle_id, process_summary_id)
    DataHub::Rollover::ProviderProcessor.process(provider_code, recruitment_cycle_id, process_summary_id)
  end
end
