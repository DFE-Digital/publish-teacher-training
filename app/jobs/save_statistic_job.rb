# frozen_string_literal: true

class SaveStatisticJob < ApplicationJob
  queue_as :save_statistic

  def perform
    StatisticService.save
  end
end
