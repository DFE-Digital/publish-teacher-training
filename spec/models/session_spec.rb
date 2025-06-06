require "rails_helper"

RSpec.describe Session, type: :model do
  let(:session) { build(:session) }

  it "#sessionable" do
    expect(session.sessionable).to be_a(Candidate)
  end

  describe "#data" do
    it "can store session data" do
      session.data["url"] = "https://find.gov.uk"
      expect(session.data).to have_key("url")

      session.data.delete("url")
      expect(session.data).not_to have_key("url")
    end
  end

  describe "#session_key" do
    it "cannot be nil" do
      session = build(:session, session_key: nil)
      expect(session).not_to be_valid
      expect(session.errors.full_messages).to include("Session key can't be blank")
    end
  end
end
