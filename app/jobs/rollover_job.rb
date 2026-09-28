# frozen_string_literal: true

class RolloverJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :default

  def perform(recruitment_cycle_id)
    DataHub::Rollover::JobOrchestrator.start_rollover(recruitment_cycle_id)
  end
end
