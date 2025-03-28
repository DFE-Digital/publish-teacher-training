# frozen_string_literal: true

class ProviderCodeGenerator
  def initialize(sequence_number)
    @sequence_number = sequence_number
    @existing_codes = Provider.pluck(:provider_code).to_set
  end

  def call
    attempt_count = 0
    possible_code = nil

    until possible_code && @existing_codes.exclude?(possible_code)
      possible_code = format("#{('A'..'Z').to_a.sample}%02d", @sequence_number % 100)

      if @existing_codes.include?(possible_code)
        attempt_count += 1
        Rails.logger.warn("ProviderCodeGenerator: Collision detected for #{possible_code}, retrying (attempt ##{attempt_count})")
      end
    end

    possible_code
  end
end
