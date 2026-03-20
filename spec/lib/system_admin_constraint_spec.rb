# frozen_string_literal: true

require "rails_helper"

RSpec.describe SystemAdminConstraint do
  subject(:constraint) { described_class.new }

  let(:request) { instance_double(ActionDispatch::Request, cookie_jar: cookie_jar) }
  let(:cookie_jar) { instance_double(ActionDispatch::Cookies::CookieJar, signed: signed_cookies) }
  let(:signed_cookies) { {} }

  describe "#matches?" do
    context "when there is no session cookie" do
      it "returns false" do
        expect(constraint.matches?(request)).to be false
      end
    end

    context "when the session cookie does not match a database session" do
      let(:signed_cookies) { { Settings.cookies.user_session.name => "nonexistent-key" } }

      it "returns false" do
        expect(constraint.matches?(request)).to be false
      end
    end

    context "when the user is not an admin" do
      let(:user) { create(:user, :with_provider) }
      let(:db_session) { create(:session, sessionable: user, session_key: "test-session-key") }
      let(:signed_cookies) { { Settings.cookies.user_session.name => db_session.session_key } }

      it "returns false" do
        expect(constraint.matches?(request)).to be false
      end
    end

    context "when the user is an admin with an active session" do
      let(:user) { create(:user, :admin) }
      let(:db_session) { create(:session, sessionable: user, session_key: "test-session-key") }
      let(:signed_cookies) { { Settings.cookies.user_session.name => db_session.session_key } }

      it "returns true" do
        expect(constraint.matches?(request)).to be true
      end
    end

    context "when the admin session has timed out" do
      let(:user) { create(:user, :admin) }
      let(:db_session) { create(:session, :timed_out, sessionable: user, session_key: "test-session-key") }
      let(:signed_cookies) { { Settings.cookies.user_session.name => db_session.session_key } }

      it "returns false" do
        expect(constraint.matches?(request)).to be false
      end

      it "destroys the timed out session" do
        constraint.matches?(request)

        expect(Session.find_by(id: db_session.id)).to be_nil
      end
    end
  end
end
