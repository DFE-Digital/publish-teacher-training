# frozen_string_literal: true

require "rails_helper"

module Authentications
  RSpec.describe DfESignInOmniAuth do
    subject(:omni_auth) { described_class.new }

    describe "#provider" do
      it "registers the OpenID Connect strategy" do
        expect(omni_auth.provider).to eq(:openid_connect)
      end
    end

    describe "#options" do
      subject(:options) { omni_auth.options }

      it "uses the email/profile scope so values are space separated" do
        expect(options[:scope]).to eq(%i[email profile])
      end

      it "configures the expected callback path and name" do
        expect(options[:callback_path]).to eq("/auth/dfe/callback")
        expect(options[:name]).to eq(:dfe)
      end

      it "sets the issuer and client options from Settings" do
        expect(options[:issuer]).to eq("https://test-oidc.signin.education.gov.uk:443")

        expect(options[:client_options]).to match(
          identifier: Settings.dfe_signin.identifier,
          port: 443,
          scheme: "https",
          host: "test-oidc.signin.education.gov.uk",
          secret: Settings.dfe_signin.secret,
          redirect_uri: "#{Settings.base_url}/auth/dfe/callback",
        )
      end
    end
  end
end
