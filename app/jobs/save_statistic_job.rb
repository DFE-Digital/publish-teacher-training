# frozen_string_literal: true

class SaveStatisticJob < ApplicationJob
  queue_as :low_priority
  retry_on_failure

  def perform
    StatisticService.save
  end
end
