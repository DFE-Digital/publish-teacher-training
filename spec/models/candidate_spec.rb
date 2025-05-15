require "rails_helper"

RSpec.describe Candidate, type: :model do
  describe "validates email_address" do
    it "validates email_address" do
      candidate = build(:candidate, email_address: "bademail")
      candidate.validate

      expect(candidate.errors.full_messages).to include("Email address Enter an email address in the correct format, like name@example.com")
    end

    it "normalizes the users email address" do
      email_address = "  withpaddingANDuppercase@email.com"
      candidate = build(:candidate, email_address:)
      candidate.save

      expect(candidate.reload.email_address).to eq("withpaddinganduppercase@email.com")
    end
  end
end
