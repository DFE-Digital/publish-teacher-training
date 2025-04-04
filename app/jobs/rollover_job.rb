# frozen_string_literal: true

class RolloverJob < ApplicationJob
  queue_as :default

  def perform(recruitment_cycle_id); end
end
