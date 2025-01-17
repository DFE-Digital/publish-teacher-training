# frozen_string_literal: true

class UpdateRatifyingProviderForCourse
  def initialize(training_provider_code:, target_ratifying_provider_code:)
    @training_provider = RecruitmentCycle.current.providers.find_by(provider_code: training_provider_code)
    @target_ratifying_provider_code = target_ratifying_provider_code
  end

  def call
    @training_provider&.courses&.each do |course|
      course.update!(accredited_provider_code: @target_ratifying_provider_code)
    end
  end
end
