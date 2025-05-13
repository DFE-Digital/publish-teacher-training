require "rails_helper"

RSpec.describe Feedback, type: :model do
  describe "validations" do
    subject { build(:feedback) }

    it { is_expected.to validate_presence_of(:ease_of_use) }
    it { is_expected.to validate_presence_of(:experience) }
    it { is_expected.to validate_length_of(:experience).is_at_most(Feedback::MAX_EXPERIENCE_LENGTH) }

    it "validates that ease_of_use is in the enum keys" do
      expect {
        described_class.new(ease_of_use: "invalid_value", experience: "Good")
      }.to raise_error(ArgumentError, /'invalid_value' is not a valid ease_of_use/)
    end
  end
end
