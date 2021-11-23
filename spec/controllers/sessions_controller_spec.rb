# frozen_string_literal: true

require "rails_helper"

describe SessionsController, type: :controller do
  include DfESignInUserHelper
  let(:user) { create(:user) }

  describe "#destroy" do
    let(:request_destroy) do
      session["user"] = {
        "last_active_at" => Time.zone.now,
        "email" => user.email,
        "id_token" => "id_token",
      }

      post :destroy
    end

    context "existing database user" do
      it "redirects to the root page" do
        request_destroy
        expect(response.location).to start_with("#{Settings.dfe_signin.issuer}/session/end")
        expect(response).to be_redirect
      end
    end

    context "non existing database user" do
      let(:user) { build(:user) }

      it "redirects to the root page" do
        request_destroy
        expect(response).to redirect_to(support_providers_path)
      end
    end
  end

  describe "#sign_out" do
    let(:request_sign_out) do
      post :sign_out
    end

    it "redirects to the auth/dfe/signout" do
      request_sign_out
      expect(response).to redirect_to("/auth/dfe/signout")
    end
  end

  describe "#callback" do
    let(:request_callback) do
      request.env["omniauth.auth"] = user_exists_in_dfe_sign_in(user: user)
      post :callback
    end

    context "existing database user" do
      it "creates a session for the signed in user" do
        request_callback
        expect(session["user"]["sign_in_user_id"]).to eq(user.sign_in_user_id)
        expect(session["user"]["email"]).to eq(user.email)

        expect(session["user"]["first_name"]).to eq(user.first_name)
        expect(session["user"]["last_name"]).to eq(user.last_name)
      end

      it "redirects to the root page" do
        request_callback
        expect(response).to redirect_to(root_path)
      end
    end

    context "non existing database user" do
      let(:user) { build(:user) }

      it "do not creates a session for the user" do
        request_callback
        expect(session["user"]).to be_nil
      end

      it "redirects to the sign in user not found page" do
        request_callback
        expect(response).to redirect_to(user_not_found_path)
      end
    end
  end
end
