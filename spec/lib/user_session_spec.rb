# frozen_string_literal: true

require "rails_helper"

describe UserSession do
  describe ".load_from_session" do
    it "returns the DfE User when the user has signed in and has been recently active" do
      session = { "user" => { "last_active_at" => Time.zone.now } }

      user = described_class.load_from_session(session)

      expect(user).not_to be_nil
    end

    it "returns nil when the user has signed in and has not been recently active" do
      session = { "user" => { "last_active_at" => 1.day.ago } }

      user = described_class.load_from_session(session)

      expect(user).to be_nil
    end

    it "returns nil when the user has not signed in" do
      session = { "user" => nil }

      user = described_class.load_from_session(session)

      expect(user).to be_nil
    end
  end
end
