require "rails_helper"

RSpec.describe Support::ConfirmEnvironment, type: :model do
  subject { described_class.new(environment: "production") }

  context "when environment does not match" do
    it "is invalid with custom message" do
      expect(subject).not_to be_valid
      expect(subject.errors[:environment]).to eq(["That's not test"])
    end
  end
end
