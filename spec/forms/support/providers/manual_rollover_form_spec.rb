require "rails_helper"

RSpec.describe Support::Providers::ManualRolloverForm, type: :model do
  subject { described_class.new(confirmation:, environment:) }

  let(:confirmation) { "" }
  let(:environment) { "" }

  context "when confirmation is blank" do
    let(:confirmation) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:confirmation]).to include("You must type 'confirm manual rollover' to proceed.")
    end
  end

  context "when confirmation is incorrect" do
    let(:confirmation) { "something else" }

    it "is invalid with custom message" do
      expect(subject).not_to be_valid
      expect(subject.errors[:confirmation]).to include("You must type 'confirm manual rollover' to proceed.")
    end
  end

  context "when environment is blank" do
    let(:environment) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:environment]).to include("You must type the environment name to proceed.")
    end
  end

  context "when environment is incorrect" do
    let(:confirmation) { "something else" }

    it "is invalid with custom message" do
      expect(subject).not_to be_valid
      expect(subject.errors[:environment]).to include("You must type the environment name to proceed.")
    end
  end

  context "when confirmation and environment is correct" do
    let(:confirmation) { "confirm manual rollover" }
    let(:environment) { "test" }

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
