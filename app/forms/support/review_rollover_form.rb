module Support
  class ReviewRolloverForm < ApplicationForm
    attr_accessor :confirmation, :environment

    CONFIRM_ROLLOVER = "confirm rollover".freeze

    validates :confirmation, :environment, presence: true
    validate :must_confirm_rollover, :must_confirm_environment

  private

    def must_confirm_rollover
      if confirmation.present? && confirmation != CONFIRM_ROLLOVER
        errors.add(:confirmation, :invalid_confirmation)
      end
    end

    def must_confirm_environment
      if environment.present? && environment != Settings.environment.name
        errors.add(:environment, :invalid_environment)
      end
    end
  end
end
