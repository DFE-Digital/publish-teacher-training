# frozen_string_literal: true

module Gias
  module Log
    def self.log(tag, message, level: :error)
      Rails.logger.tagged(tag) { |l| l.send(level, message) }
    end
  end
end
