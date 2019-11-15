require "rails_helper"

describe API::V2::ApplicationController, type: :controller do
  describe "#authenticate" do
    let(:secret) { Settings.authentication.secret }
    let(:encoded_token) do
      JWT.encode(
        payload,
        secret,
        Settings.authentication.algorithm,
      )
    end
    let(:bearer_token) { "Bearer #{encoded_token}" }

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

      it { should eq "HTTP Token: Access denied.\n" }

      it "requests authentication via the http header" do
        subject

        expect(response.headers["WWW-Authenticate"])
          .to eq('Token realm="Application"')
      end
    end

    describe "manage course api integration" do
      let(:email) { "manage_courses@api.com" }
      let(:sign_in_user_id) { "manage_courses_api" }
      let(:existing_user) { create(:user, email: email, sign_in_user_id: sign_in_user_id) }
      let(:secret) { Settings.authentication.secret = "SETTINGS:MANAGE_BACKEND:SECRET" }

      before do
        existing_user
        Settings.authentication.secret = "SETTINGS:MANAGE_BACKEND:SECRET"
      end

      # NOTES:
      # This is hardcode as the ruby version of JWT encoding is not symmetrical with csharp and does not applies
      #
      # RECOMMENDED (Notational Conventions) for the "typ" (Type) Header Parameter see (https://tools.ietf.org/html/rfc7519#section-5.1)
      # as default.
      # In any case as long as it can be verified it is fine.
      let(:encoded_token) do
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaWduX2luX3VzZXJfaWQiOiJtYW5hZ2VfY291cnNlc19hcGkiLCJlbWFpbCI6Im1hbmFnZV9jb3Vyc2VzQGFwaS5jb20ifQ.fs0tM5Lc_5vA2w94PhlDMnq50NUn2K5SMxggdAApp_w"
      end

      it "assigns the user" do
        controller.authenticate

        expect(assigns(:current_user)).to eq existing_user
      end
    end
  end

  describe "#append_info_to_payload" do
    it "sets the request_id in the payload to the request uuid" do
      payload = {}
      request_uuid = SecureRandom.uuid

      allow(request).to receive(:uuid).and_return(request_uuid)

      controller.__send__(:append_info_to_payload, payload)

      expect(payload[:request_id]).to eq request_uuid
    end
  end
end
