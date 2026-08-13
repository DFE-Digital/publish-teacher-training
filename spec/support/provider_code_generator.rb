# frozen_string_literal: true

class ProviderCodeGenerator
  def initialize(sequence_number)
    @sequence_number = sequence_number
    @existing_codes = Provider.pluck(:provider_code).to_set
    @unwanted_codes = @existing_codes
  end

  def call(avoid: [])
    attempt_count = 0
    possible_code = nil
    @unwanted_codes += avoid

    until possible_code && @unwanted_codes.exclude?(possible_code)
      possible_code = sprintf("#{('A'..'Z').to_a.sample}%02d", @sequence_number % 100)

      if @unwanted_codes.include?(possible_code)
        attempt_count += 1
        Rails.logger.warn("ProviderCodeGenerator: Collision detected for #{possible_code}, retrying (attempt ##{attempt_count})")
      end
    end

    possible_code
  end
end
