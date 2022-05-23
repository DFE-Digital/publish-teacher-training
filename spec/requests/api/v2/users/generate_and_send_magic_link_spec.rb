require "rails_helper"

describe "PATCH /api/v2/users/generate_and_send_magic_link", type: :request do
  let(:user)    { create(:user) }
  let(:payload) { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }

  def perform_request
    patch(
      generate_and_send_magic_link_api_v2_users_path,
      headers: { "HTTP_AUTHORIZATION" => credentials },
      params: {},
    )
  end

  context "when authenticated and authorised" do
    it "returns the status OK" do
      perform_request

      expect(response).to have_http_status(:no_content)
    end

    it "stores the magic link in the user table" do
      perform_request

      system_user = User.find_by(email: user.email)
      expect(system_user.magic_link_token).not_to be_nil
      expect(system_user.magic_link_token_sent_at).to be_within(10.seconds).of Time.now.utc
    end

    it "sends an email with the magic link" do
      perform_request

      system_user = User.find_by(email: user.email)
      expect(system_user.magic_link_token).not_to be_nil
    end
  end

  context "when user has not accepted terms and conditions" do
    let(:user) { create(:user, :inactive) }

    it "returns status 204 No Content" do
      perform_request
      expect(response).to have_http_status(:no_content)
    end
  end
end
