module Support
  class ReviewRolloverForm < ApplicationForm
    attr_accessor :confirmation

    CONFIRM_ROLLOVER = "confirm rollover".freeze

    validates :confirmation, presence: true
    validate :must_confirm_rollover

  private

    def must_confirm_rollover
      if confirmation.present? && confirmation != CONFIRM_ROLLOVER
        errors.add(:confirmation, :invalid_confirmation)
      end
    end
  end
end
