require "rails_helper"

module Authentications
  RSpec.describe CandidateOmniAuth do
    subject { described_class.new }

    describe "#provider" do
      context "when Setting.one_login.enabled is false" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(false)
        end

        it "sets provider to :find_developer" do
          expect(subject.provider).to eq(:find_developer)
        end
      end

      context "when Setting.one_login.enabled is true" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(true)
        end

        it "sets provider to :govuk_one_login" do
          expect(subject.provider).to eq(:govuk_one_login)
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
          expect(subject.options).to eq(expected)
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

          expect(subject.options).to eq(expected)
        end
      end
    end

    describe "#config" do
      context "when Setting.one_login.enabled is false and env is not local" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(false)
          allow(Rails.env).to receive(:local?).and_return(false)
        end

        it "does not yield" do
          expect { |b| subject.config(&b) }.not_to yield_control
        end
      end

      context "when Setting.one_login.enabled is false and env is local" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(false)
        end

        it "does yield" do
          expect { |b| subject.config(&b) }.to yield_control
        end
      end

      context "when Setting.one_login.enabled is true" do
        before do
          allow(Settings.one_login).to receive(:enabled).and_return(true)
        end

        it "sets provider to :govuk_one_login" do
          expect(subject.provider).to eq(:govuk_one_login)
        end
      end
    end
  end
end
