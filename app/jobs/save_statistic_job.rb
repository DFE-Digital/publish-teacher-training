# frozen_string_literal: true

class SaveStatisticJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :low_priority
  retry_on_failure

  def perform
    StatisticService.save
  end
end
