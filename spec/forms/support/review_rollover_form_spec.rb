require "rails_helper"

RSpec.describe Support::ReviewRolloverForm, type: :model do
  subject { described_class.new(confirmation:) }

  context "when confirmation is blank" do
    let(:confirmation) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:confirmation]).to include("You must type 'confirm rollover' to proceed.")
    end
  end

  context "when confirmation is incorrect" do
    let(:confirmation) { "something else" }

    it "is invalid with custom message" do
      expect(subject).not_to be_valid
      expect(subject.errors[:confirmation]).to include("You must type 'confirm rollover' to proceed.")
    end
  end

  context "when confirmation is correct" do
    let(:confirmation) { "confirm rollover" }

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
