# frozen_string_literal: true

require "rails_helper"

describe SessionsController, type: :controller do
  include DfESignInUserHelper
  let(:user) { create(:user) }
  let(:request_callback) do
    request.env["omniauth.auth"] = user_exists_in_dfe_sign_in(user: user)
    post :create
  end

  describe "#callback" do
    context "existing database user" do
      it "creates a session for the signed in user" do
        request_callback
        expect(session["sign_in_session"]["sign_in_user_id"]).to eq(user.sign_in_user_id)
        expect(session["sign_in_session"]["email"]).to eq(user.email)

        expect(session["sign_in_session"]["first_name"]).to eq(user.first_name)
        expect(session["sign_in_session"]["last_name"]).to eq(user.last_name)
      end

      it "redirects to the gias dashboard page" do
        request_callback
        expect(response).to redirect_to(gias_dashboard_path)
      end
    end

    context "non existing database user" do
      let(:user) { build(:user) }
      it "do not creates a session for the user" do
        request_callback
        expect(session["sign_in_session"]).to be_nil
      end

      it "redirects to the sign in user not found page" do
        request_callback
        expect(response).to redirect_to(user_not_found_path)
      end
    end
  end
end
