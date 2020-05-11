require "rails_helper"

describe "POST /sessions/create_by_magic" do
  let(:user)    { create(:user, :with_magic_link_token) }
  let(:payload) { { email: email } }
  let(:email)   { user.email }
  let(:magic_link_token) { user.magic_link_token }
  let(:params) { { magic_link_token: magic_link_token } }

  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def perform_request
    patch(
      create_by_magic_api_v2_sessions_path,
      headers: { "HTTP_AUTHORIZATION" => credentials },
      params: params,
    )
  end

  context "token and email are correct" do
    it "sets the user's token and sent_at to nil" do
      perform_request

      user.reload
      expect(user.magic_link_token).to be_nil
      expect(user.magic_link_token_sent_at).to be_nil
    end

    it "sets the user's last login date" do
      perform_request

      user.reload
      expect(user.last_login_date_utc).to be_within(4.seconds).of Time.now.utc
    end

    it "records the first login" do
      user.update(first_login_date_utc: nil)

      perform_request

      user.reload
      expect(user.first_login_date_utc).to be_within(4.seconds).of Time.now.utc
    end

    it "sends a welcome email" do
      user.update(welcome_email_date_utc: nil)
      expect {
        perform_request
      } .to(
        have_enqueued_email(WelcomeEmailMailer, :send_welcome_email)
            .with { user.reload; { first_name: user.first_name, email: user.email } }
            .on_queue(:mailer),
      )
    end

    it "renders the user" do
      perform_request

      returned_json_response = JSON.parse response.body
      data_attributes = returned_json_response["data"]["attributes"]

      expect(data_attributes["email"]).to eq(user.email)
      expect(data_attributes["first_name"]).to eq(user.first_name)
      expect(data_attributes["last_name"]).to eq(user.last_name)
      expect(data_attributes["state"]).to eq(user.state)
    end
  end

  context "token is invalid" do
    let(:magic_link_token) { "deadbeef" }

    it "should return forbidden" do
      perform_request

      expect(response).to have_http_status(:forbidden)
    end

    it "does not invalidate the token" do
      perform_request

      user.reload

      expect(user.magic_link_token).not_to be_nil
      expect(user.magic_link_token_sent_at).not_to be_nil
    end
  end

  context "email is invalid" do
    let(:email) { "somebody@localhost" }

    it "should return unauthorized" do
      perform_request

      expect(response).to have_http_status(:unauthorized)
    end

    it "does not invalidate the token" do
      perform_request

      user.reload

      expect(user.magic_link_token).not_to be_nil
      expect(user.magic_link_token_sent_at).not_to be_nil
    end
  end
end
