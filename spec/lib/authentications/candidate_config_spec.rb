require "rails_helper"

module Authentications
  RSpec.describe CandidateConfig do
    let(:config) { described_class.new }

    describe "#provider" do
      context "when Setting.one_login.enabled is false" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(false)
        end

        it "sets provider to :find_developer" do
          expect(config.provider).to eq(:find_developer)
        end
      end

      context "when Setting.one_login.enabled is true" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(true)
        end

        it "sets provider to :govuk_one_login" do
          expect(config.provider).to eq(:govuk_one_login)
        end
      end
    end

    describe "#options" do
      context "when one_login" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(true)
        end

        it "sets provider to :govuk_one_login" do
          expected = {
            name: :"one-login",
            client_id: Settings.one_login.identifier,
            idp_base_url: Settings.one_login.idp_base_url,
            redirect_uri: "http://find.localhost/auth/one-login/callback",
            private_key: nil,
          }
          expect(config.options).to eq(expected)
        end
      end

      context "when find_developer" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(false)
        end

        it "sets provider to :govuk_one_login" do
          expected = {
            name: "find-developer",
            fields: %i[uid email],
            uid_field: :uid,
            path_prefix: "/auth",
            callback_path: "/auth/find-developer/callback",
          }

          expect(config.options).to eq(expected)
        end
      end
    end
  end
end
