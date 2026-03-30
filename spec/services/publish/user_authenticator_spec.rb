# frozen_string_literal: true

require "rails_helper"

module Publish
  describe UserAuthenticator do
    subject(:authenticator) { described_class.new(oauth:) }

    let(:oauth) do
      OmniAuth::AuthHash.new(
        "provider" => "dfe",
        "uid" => SecureRandom.uuid,
        "info" => {
          "email" => email,
          "first_name" => "Jane",
          "last_name" => "Smith",
        },
      )
    end

    let(:email) { "user@example.com" }

    context "when user exists with matching email" do
      let!(:user) { create(:user, email:) }

      it "returns the user" do
        expect(authenticator.call).to eq(user)
      end

      it "updates last_login_date_utc" do
        freeze_time do
          authenticator.call
          expect(user.reload.last_login_date_utc).to eq(Time.zone.now)
        end
      end

      it "updates first_name from oauth" do
        authenticator.call
        expect(user.reload.first_name).to eq("Jane")
      end

      it "updates last_name from oauth" do
        authenticator.call
        expect(user.reload.last_name).to eq("Smith")
      end

      it "does not update first_name when oauth value is blank" do
        oauth.info.first_name = ""
        expect { authenticator.call }.not_to(change { user.reload.first_name })
      end

      it "does not update last_name when oauth value is blank" do
        oauth.info.last_name = ""
        expect { authenticator.call }.not_to(change { user.reload.last_name })
      end
    end

    context "when no user exists with that email" do
      it "returns nil" do
        expect(authenticator.call).to be_nil
      end
    end
  end
end
