# frozen_string_literal: true

class RolloverProviderJob
  include Sidekiq::Job

  def perform(provider_code)
    RolloverProviderService.call(provider_code:, force: false)
  end
end
