require "rails_helper"

describe '/api/v2/sessions', type: :request do
  let(:user)    { create(:user) }
  let(:payload) { { email: user.email } }
  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  context 'when unauthenticated' do
    let(:payload) { { email: 'foo@bar' } }

    before do
      post "/api/v2/sessions",
          headers: { 'HTTP_AUTHORIZATION' => credentials }
    end

    subject { response }

    it { should have_http_status(:unauthorized) }
  end

  describe 'creating a session' do
    let(:params) do
      {
        "_jsonapi" => {
            "data" => {
              "type" => type,
              "attributes" => attributes
            }
        }
      }
    end

    context "session resource type" do
      let(:type) { "sessions" }
      let(:attributes) do
        {
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        }
      end

      let(:user) { create(:user, last_login_date_utc: 10.days.ago) }
      let(:returned_json_response) { JSON.parse response.body }

      before do
        Timecop.freeze
        post '/api/v2/sessions',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: params
      end

      after do
        Timecop.return
      end

      it 'saves the last login time' do
        # OS vs TimeCop vs db, most likely db (nanoseconds are omitted), hence
        # 'be_within(1.second).of Time.now.utc' vs 'eq Time.now.utc'
        expect(user.reload.last_login_date_utc).to be_within(1.second).of Time.now.utc
      end

      describe "the returned json" do
        it 'returns the user record' do
          expect(returned_json_response).to eq(
            "data" => {
              "id" => user.id.to_s,
              "type" => "users",
              "attributes" => {
                "first_name" => user.first_name,
                "last_name" => user.last_name,
                "email" => user.email,
              }
            },
            "jsonapi" => {
              "version" => "1.0"
            }
          )
        end
      end

      context "new user details" do
        let(:attributes) do
          {
            "first_name" => "updated first_name",
            "last_name" => "updated last_name",
          }
        end

        it 'returns the updated user record' do
          expect(returned_json_response['data']).to have_attribute(:first_name).with_value('updated first_name')
          expect(returned_json_response['data']).to have_attribute(:last_name).with_value('updated last_name')
        end

        it "updated user details" do
          user.reload
          expect(user.first_name).to eq "updated first_name"
          expect(user.last_name).to eq "updated last_name"
        end
      end

      context "unpermitted fields" do
        let(:attributes) do
          {
            "email" => "updated first_name",
          }
        end

        it 'returns the user record with old email' do
          expect(returned_json_response['data']).to have_attribute(:email).with_value(user.email)
        end
      end
    end

    context "invalid resource type" do
      let(:attributes) do
        {
          "first_name" => "update invalid first_name",
          "last_name" => "updated invalid last_name",
        }
      end
      let(:type) { "invalid" }
      let(:returned_json_response) { JSON.parse response.body }

      # session type
      # pp params[:session]
      # <ActionController::Parameters {"type"=>"session", "first_name"=>"update invalid first_name", "last_name"=>"updated invalid last_name"} permitted: false>

      # invalid type
      # pp params[:session]
      #<ActionController::Parameters {"type"=>"invalid", "first_name"=>"update invalid first_name", "last_name"=>"updated invalid last_name"} permitted: false>


      # concerns are "first_name" & "last_name" and not "type" == "session"
      it 'raises an error' do
        expect {
          post '/api/v2/sessions',
               headers: { 'HTTP_AUTHORIZATION' => credentials },
               params: params
        }.to raise_error(ActionController::BadRequest)
      end

      it 'does not update user record' do
        expect {
          post(
            '/api/v2/sessions',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: params
          ) rescue nil
        }.not_to(change { user.reload })
      end
    end
  end

  context "no params" do
    # deserializable_resource :session
    # from jsonapi-rails seems to enforce expectation
    it 'does not update user record' do
      expect {
        post(
          '/api/v2/sessions',
          headers: { 'HTTP_AUTHORIZATION' => credentials }
        ) rescue nil
      }.not_to(change { user.reload })
    end
  end
end
