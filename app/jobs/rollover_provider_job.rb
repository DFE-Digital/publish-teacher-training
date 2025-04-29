# frozen_string_literal: true

class RolloverProviderJob
  include Sidekiq::Job

  def perform(provider_code, new_recruitment_cycle_id)
    RolloverProviderService.call(
      provider_code:,
      new_recruitment_cycle_id:,
      force: false,
    )
  end
end
