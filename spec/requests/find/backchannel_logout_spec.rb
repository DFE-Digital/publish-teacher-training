# frozen_string_literal: true

require "rails_helper"

describe "/auth/one-login/backchannel-logout", service: :find do
  context "when page parameter is invalid" do
    before do
      FeatureFlag.activate(:candidate_accounts)
    end

    it "returns 400 when params is empty" do
      post "/auth/find-developer/backchannel-logout", params: {}

      expect(response).to have_http_status(:bad_request)
    end

    context "making request" do
      before do
        @utility = instance_double(OmniAuth::GovukOneLogin::BackchannelLogoutUtility)
        allow(OmniAuth::GovukOneLogin::BackchannelLogoutUtility).to receive(:new).and_return(@utility)
      end

      let(:subject_key) { "UID" }

      it "return 400 when UID is blank" do
        allow(@utility).to receive(:get_sub).with(logout_token: anything).and_return("")
        post "/auth/find-developer/backchannel-logout", params: { logout_token: "TOKEN" }

        expect(response).to have_http_status(:bad_request)
      end

      it "return 400 when authentication is not found" do
        allow(@utility).to receive(:get_sub).with(logout_token: anything).and_return(subject_key)
        post "/auth/find-developer/backchannel-logout", params: { logout_token: "TOKEN" }

        expect(response).to have_http_status(:not_found)
      end

      it "return 400 when provider does not match the authentication" do
        allow(@utility).to receive(:get_sub).with(logout_token: anything).and_return(subject_key)
        auth = create(:authentication, subject_key:)
        create(:session, sessionable: auth.authenticable)

        post "/auth/other-provider/backchannel-logout", params: { logout_token: "TOKEN" }

        expect(response).to have_http_status(:not_found)
      end

      it "return 200 when successful" do
        allow(@utility).to receive(:get_sub).with(logout_token: anything).and_return(subject_key)
        auth = create(:authentication, subject_key:)
        create(:session, sessionable: auth.authenticable)

        post "/auth/find-developer/backchannel-logout", params: { logout_token: "TOKEN" }

        expect(auth.authenticable.sessions).to be_blank
        expect(response).to have_http_status(:successful)
      end
    end
  end
end
