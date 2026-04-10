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

  describe "#active?" do
    context "when the session belongs to a User" do
      it "returns true when updated within the timeout period" do
        session = create(:session, :active, sessionable: create(:user))

        expect(session).to be_active
      end

      it "returns false when updated beyond the timeout period" do
        session = create(:session, :timed_out, sessionable: create(:user))

        expect(session).not_to be_active
      end

      it "returns false at exactly the timeout boundary" do
        session = create(:session, sessionable: create(:user))
        session.update_columns(updated_at: Session::INACTIVITY_TIMEOUT.ago)

        expect(session).not_to be_active
      end
    end

    context "when the session belongs to a Candidate" do
      it "returns true when updated within the timeout period" do
        session = create(:session, :active, sessionable: create(:candidate))

        expect(session).to be_active
      end

      it "returns false when updated beyond the timeout period" do
        session = create(:session, :timed_out, sessionable: create(:candidate))

        expect(session).not_to be_active
      end
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
