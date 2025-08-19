# frozen_string_literal: true

class RolloverJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 1
  STAGGER_OVER = 3

  def perform(recruitment_cycle_id)
    relation = RecruitmentCycle.current_recruitment_cycle.providers

    BatchDelivery.new(
      relation:,
      stagger_over: STAGGER_OVER.hours,
      batch_size: BATCH_SIZE,
    ).each do |batch_time, providers|
      providers.pluck(:provider_code).each do |provider_code|
        RolloverProviderJob.perform_at(batch_time, provider_code, recruitment_cycle_id)
      end
    end
  end
end
