require "rails_helper"

describe API::V2::ApplicationController, type: :controller do
  describe "#authenticate" do
    let(:secret) { Settings.authentication.secret }
    let(:bearer_token) { encode_to_bearer_token(payload) }

    before do
      controller.response              = response
      request.headers["Authorization"] = bearer_token
    end

    subject { controller.authenticate }

    context "with an email in the payload that matches a user" do
      let(:user)    { create(:user) }
      let(:payload) { { email: user.email } }

      it "saves the user for use by the action" do
        controller.authenticate

        expect(assigns(:current_user)).to eq user
      end
    end

    context "with an email in the payload that does not match a user" do
      let(:payload) { { email: Faker::Internet.email } }

      it { is_expected.to eq "HTTP Token: Access denied.\n" }

      it "requests authentication via the http header" do
        subject

        expect(response.headers["WWW-Authenticate"])
          .to eq('Token realm="Application"')
      end
    end
  end

  describe "#store_request_id" do
    it "stores the request id" do
      request_uuid = SecureRandom.uuid

      allow(request).to receive(:uuid).and_return(request_uuid)
      allow(RequestStore).to receive(:store).and_return({})

      controller.__send__(:store_request_id)

      expect(RequestStore.store).to eq(request_id: request_uuid)
    end
  end

  describe "#append_info_to_payload" do
    it "sets the request_id in the payload to the request uuid" do
      payload = {}
      request_uuid = SecureRandom.uuid
      controller.response = response

      allow(RequestStore).to receive(:store).and_return(request_id: request_uuid)

      controller.__send__(:append_info_to_payload, payload)

      expect(payload[:request_id]).to eq request_uuid
    end
  end
end
