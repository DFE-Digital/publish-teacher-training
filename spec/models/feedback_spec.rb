require "rails_helper"

RSpec.describe Feedback, type: :model do
  describe "validations" do
    subject { build(:feedback) }

    it { is_expected.to validate_presence_of(:ease_of_use) }
    it { is_expected.to validate_presence_of(:experience) }
    it { is_expected.to validate_length_of(:experience).is_at_most(1200) }
  end
end
