# frozen_string_literal: true

class UpdateRatifyingProviderForCourse
  # PROVIDERS = %w[5W1 1BJ 24H 4R4 2a5].freeze
  # TARGET_PROVIDER = '3A1'

  def initialize(training_provider_code:, target_ratifying_provider_code:)
    @training_provider = RecruitmentCycle.current.providers.find_by(provider_code: training_provider_code)
    @target_ratifying_provider_code = target_ratifying_provider_code
  end

  def call
    @training_provider.courses.each do |course|
      course.update!(accredited_provider_code: @target_ratifying_provider_code)
    end
  end
end
