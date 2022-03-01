require "rails_helper"

describe "/api/v2/users", type: :request do
  let(:user) { create :user, first_name: "Bob", last_name: "Kim", email: "bob.kim@local" }
  let(:payload) { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }

  context "when unauthenticated" do
    let(:payload) { { email: "foo@bar" } }

    before do
      get "/api/v2/users/#{user.id}",
          headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    subject { response }

    it { is_expected.to have_http_status(:unauthorized) }
  end

  context "when unauthorized" do
    let(:unauthorised_user) { create(:user) }
    let(:payload) { { email: unauthorised_user.email } }

    it "raises an error" do
      expect {
        get "/api/v2/users/#{user.id}",
            headers: { "HTTP_AUTHORIZATION" => credentials }
      }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "JSON generated for a user" do
    before do
      get "/api/v2/users/#{user.id}",
          headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    subject { response }

    it { is_expected.to have_http_status(:success) }

    it "has a data section with the correct attributes" do
      json_response = JSON.parse(response.body)
      data_attributes = json_response["data"]["attributes"]

      expect(data_attributes["email"]).to eq(user.email)
      expect(data_attributes["first_name"]).to eq(user.first_name)
      expect(data_attributes["last_name"]).to eq(user.last_name)
      expect(data_attributes["state"]).to eq(user.state)
      expect(data_attributes["associated_with_accredited_body"]).to be(false)
      expect(data_attributes["notifications_configured"]).to be(false)
    end

    context "when user is associated with an accredited body" do
      let(:user) { create(:user, providers: [accredited_body]) }
      let(:accredited_body) { create(:provider, :accredited_body) }

      it "has a data section with the correct attribute" do
        json_response = JSON.parse(response.body)
        data_attributes = json_response["data"]["attributes"]

        expect(data_attributes["associated_with_accredited_body"]).to be(true)
      end
    end

    context "when user has notifications configured" do
      let(:user) { create(:user, user_notifications: [create(:user_notification)]) }

      it "has a data section with the correct attribute" do
        json_response = JSON.parse(response.body)
        data_attributes = json_response["data"]["attributes"]

        expect(data_attributes["notifications_configured"]).to be(true)
      end
    end
  end

  describe "PATCH update" do
    let(:params) { {} }

    def perform_request
      Timecop.freeze do
        patch(
          api_v2_user_path(user),
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: params,
        )
      end
    end

    context "when authenticated and authorised" do
      let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
      let(:update_params) { %i[first_name last_name email] }
      let(:params) do
        # simulate the JSONAPI params we would send in, but be sure to remove
        # 'state' which is automatically included by the serialiser
        {
          _jsonapi: jsonapi_renderer.render(
            user,
            class: {
              User: API::V2::SerializableUser,
            },
          ).tap { |json| json[:data][:attributes].slice!(update_params) },
        }
      end
      let(:user_params)           { params.dig :_jsonapi, :data, :attributes }
      let(:accept_terms_date_utc) { DateTime.now.utc }
      let(:email)                 { "dave.smith@gmail.com" }
      let(:first_name)            { "Dave" }
      let(:last_name)             { "Smith" }
      let(:json_data)             { JSON.parse(response.body)["data"] }

      before do
        user_params.merge!(
          email: email,
          accept_terms_date_utc: accept_terms_date_utc,
          first_name: first_name,
          last_name: last_name,
        )
      end

      subject { perform_request }

      it "updates email on the user" do
        expect { subject }.to(
          change { user.reload.email }
            .from(user.email)
            .to(email),
        )
      end

      it "updates accept_terms_date_utc on the user" do
        expect { subject }.to(
          change { user.reload.accept_terms_date_utc }
            .from(user.accept_terms_date_utc.change(usec: 0))
            .to(accept_terms_date_utc.change(usec: 0)),
        )
      end

      it "updates first_name on the user" do
        expect { subject }.to(
          change { user.reload.first_name }
            .from(user.first_name)
            .to(first_name),
        )
      end

      it "updates last_name on the user" do
        expect { subject }.to(
          change { user.reload.last_name }
            .from(user.last_name)
            .to(last_name),
        )
      end

      context "response output" do
        before do
          perform_request
        end

        subject { response }

        it { is_expected.to have_http_status(:success) }

        it "returns a JSON repsentation of the updated user" do
          subject

          expect(json_data).to have_id(user.id.to_s)
          expect(json_data).to have_type("users")
          expect(json_data).to have_jsonapi_attributes(
            :email,
            :first_name,
            :last_name,
            :accept_terms_date_utc,
          )
        end

        context "with validation errors" do
          let(:json_data) { JSON.parse(response.body)["errors"] }

          context "with missing attributes" do
            let(:email) { "" }

            it { is_expected.to have_http_status(:unprocessable_entity) }

            it "checks the email is present" do
              expect(response.body).to include("Invalid email")
              expect(response.body).to include("Email can't be blank")
            end
          end
        end
      end
    end
  end
end
