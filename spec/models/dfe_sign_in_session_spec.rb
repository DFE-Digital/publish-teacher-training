# frozen_string_literal: true

require "rails_helper"

describe DfESignInSession do
  describe ".load_from_session" do
    it "returns the DfE User when the user has signed in and has been recently active" do
      session = { "sign_in_session" => { "last_active_at" => Time.zone.now } }

      user = DfESignInSession.load_from_session(session)

      expect(user).not_to be_nil
    end

    it "returns nil when the user has signed in and has not been recently active" do
      session = { "sign_in_session" => { "last_active_at" => Time.zone.now - 1.day } }

      user = DfESignInSession.load_from_session(session)

      expect(user).to be_nil
    end

    it "returns nil when the user has not signed in" do
      session = { "sign_in_session" => nil }

      user = DfESignInSession.load_from_session(session)

      expect(user).to be_nil
    end

    it "returns nil when the user does not have a last active timestamp" do
      session = { "sign_in_session" => { "last_active_at" => nil } }

      user = DfESignInSession.load_from_session(session)

      expect(user).to be_nil
    end
  end
end
