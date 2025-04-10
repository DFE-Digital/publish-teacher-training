# frozen_string_literal: true

class RolloverJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 10

  def perform(recruitment_cycle_id)
    relation = RecruitmentCycle.current_recruitment_cycle.providers

    BatchDelivery.new(relation:, stagger_over: 1.hour, batch_size: BATCH_SIZE).each do |batch_time, providers|
      RolloverProvidersBatchJob.perform_at(batch_time, providers.pluck(:provider_code))
    end
  end
end

 class RolloverProvidersBatchJob < ApplicationJob
   queue_as :default

   def perform(provider_codes)
     provider_codes.each do |provider_code|
       RolloverProviderJob.perform(provider_code)
     end
   end
 end

class RolloverProviderJob < ApplicationJob
  queue_as :default

  def perform(provider_code)
    RolloverProviderService.call(provider_code:, force: false)
  end
end
