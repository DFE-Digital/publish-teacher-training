require "rails_helper"

describe "Access Request API V2", type: :request do
  # Specify a fixed admin email to avoid randomisation from the factory, must qualify as #admin?
  let(:admin_user) { create(:user, :admin) }
  let(:requesting_user) { create(:user, organisations: [organisation]) }
  let(:requested_user) { create(:user) }
  let(:organisation) { create(:organisation) }
  let(:payload) { { email: admin_user.email } }
  let(:access_request) {
    create(:access_request,
           email_address: requested_user.email,
           requester_email: requesting_user.email,
           requester_id: requesting_user.id,
           organisation: organisation.name)
  }
  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  subject { response }

  describe "GET #index" do
    let(:access_requests_index_route) do
      get "/api/v2/access_requests",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: { include: "requester" }
    end

    context "when unauthenticated" do
      before do
        access_requests_index_route
      end

      let(:payload) { { email: "foo@bar" } }

      it { should have_http_status(:unauthorized) }
    end

    context "when unauthorized" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }
      let(:unauthorised_user_route) do
        get "/api/v2/access_requests",
            headers: { "HTTP_AUTHORIZATION" => credentials }
      end


      it "should raise an error" do
        expect { unauthorised_user_route }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when authorised" do
      let!(:access_request_1) { create(:access_request) }
      let!(:access_request_2) { create(:access_request) }

      before do
        access_requests_index_route
      end

      it "renders a JSONAPI response with a list of access requests" do
        json_response         = JSON.parse(response.body)["data"]
        access_request_1_json = json_response.first
        access_request_2_json = json_response.second

        expect(access_request_1_json).to have_id(access_request_1.id.to_s)
        expect(access_request_2_json).to have_id(access_request_2.id.to_s)

        expect(access_request_1_json).to have_type("access_request")
        expect(access_request_2_json).to have_type("access_request")

        expect(access_request_1_json).to have_relationship(:requester)
        expect(access_request_2_json).to have_relationship(:requester)

        expect(access_request_1_json).to have_attributes(
          :email_address,
          :first_name,
          :last_name,
          :requester_email,
          :requester_id,
          :organisation,
          :reason,
          :request_date_utc,
          :status,
        )
        expect(access_request_2_json).to have_attributes(
          :email_address,
          :first_name,
          :last_name,
          :requester_email,
          :requester_id,
          :organisation,
          :reason,
          :request_date_utc,
          :status,
        )
      end
    end
  end

  describe "GET #show" do
    let(:first_access_request) { create(:access_request) }
    let(:access_requests_show_route) do
      get "/api/v2/access_requests/#{first_access_request.id}",
          headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    context "when unauthenticated" do
      before do
        access_requests_show_route
      end

      let(:payload) { { email: "foo@bar" } }

      it { should have_http_status(:unauthorized) }
    end

    context "when unauthorized" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "should raise an error" do
        expect { access_requests_show_route }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when authorised" do
      before do
        Timecop.freeze
        access_requests_show_route
      end

      after do
        Timecop.return
      end

      it "JSON displays the correct attributes" do
        json_response = JSON.parse response.body

        expect(json_response).to eq(
          "data" => {
            "id" => first_access_request.id.to_s,
            "type" => "access_request",
            "attributes" => {
              "email_address" => first_access_request.recipient.email,
              "first_name" => first_access_request.recipient.first_name,
              "last_name" => first_access_request.recipient.last_name,
              "requester_email" => first_access_request.requester.email,
              "requester_id" => first_access_request.requester.id,
              "organisation" => first_access_request.organisation,
              "reason" => first_access_request.reason,
              "request_date_utc" => first_access_request.request_date_utc.iso8601,
              "status" => first_access_request.status,
            },
            "relationships" => {
              "requester" => {
                "data" => {
                  "type" => "users",
                  "id" => first_access_request.requester.id.to_s,
                },
              },
            },
          },
          "included" => [{
            "id" => first_access_request.requester.id.to_s,
            "type" => "users",
            "attributes" => {
              "first_name" => first_access_request.requester.first_name,
              "last_name" => first_access_request.requester.last_name,
              "email" => first_access_request.requester.email,
              "accept_terms_date_utc" => first_access_request.requester.accept_terms_date_utc.utc.strftime("%FT%T.%3NZ"),
              "state" => first_access_request.requester.state,
              "admin" => first_access_request.requester.admin,
            },
          }],
          "jsonapi" => {
            "version" => "1.0",
          },
         )
      end
    end

    context "when discarded" do
      let(:first_access_request) do
        access_request = create(:access_request)
        access_request.discard
        access_request
      end

      before do
        access_requests_show_route
      end

      it { should have_http_status(:not_found) }
    end
  end

  describe "POST #approve" do
    let(:approve_route_request) do
      post "/api/v2/access_requests/#{access_request.id}/approve",
           headers: { "HTTP_AUTHORIZATION" => credentials }
    end
    context "when unauthenticated" do
      before do
        approve_route_request
      end

      let(:payload) { { email: "foo@bar" } }

      it { should have_http_status(:unauthorized) }
    end

    context "when unauthorized" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "should raise an error" do
        expect { approve_route_request }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when authorised" do
      before do
        approve_route_request
      end

      it "updates the requests status to completed" do
        expect(access_request.reload.status). to eq "completed"
      end

      it "has a successful response" do
        expect(response.body).to eq({ result: true }.to_json)
      end

      context "when the user requested user already exists" do
        it "gives a pre existing user access to the right organisations" do
          expect(requested_user.organisations).to eq requesting_user.organisations
        end
      end

      context "when email address does not belong to a user" do
        let(:new_user_access_request) {
          create(:access_request,
                 first_name: "test",
                 last_name: "user",
                 email_address: "test@user.com",
                 requester_email: requesting_user.email,
                 requester_id: requesting_user.id,
                 organisation: organisation.name)
        }
        before do
          post "/api/v2/access_requests/#{new_user_access_request.id}/approve",
               headers: { "HTTP_AUTHORIZATION" => credentials }
        end

        it "creates a new account for a new user and gives access to the right orgs" do
          new_user = User.find_by!(email: "test@user.com")

          expect(new_user.organisations).to eq requesting_user.organisations
        end
      end
    end
  end

  describe "POST #create" do
    let(:params) {
      {
        access_request: {
          email_address: "bob@example.org",
          first_name: "bob",
          last_name: "monkhouse",
          organisation: "bbc",
          reason: "star qualities",
          requester_email: requesting_user.email,
        },
      }
    }

    let(:do_post) do
      post "/api/v2/access_requests",
           headers: { "HTTP_AUTHORIZATION" => credentials },
           params: params.as_json
    end
    context "when unauthenticated" do
      before do
        do_post
      end

      let(:payload) { { email: "foo@bar" } }

      it { should have_http_status(:unauthorized) }
    end

    context "authorises non-admin users" do
      let(:non_admin_user) { create(:user) }
      let(:payload) { { email: non_admin_user.email } }

      before do
        do_post
      end

      it { should have_http_status(:ok) }
    end

    context "when authorised" do
      before do
        Timecop.freeze
        do_post
      end

      after do
        Timecop.return
      end

      describe "successful validation" do
        it "returns the correct id" do
          string_id = JSON.parse(response.body)["data"]["id"]
          id = Integer(string_id)

          expect(id).to be > 0
        end

        describe "JSON returns the correct attributes" do
          subject { JSON.parse(response.body)["data"]["attributes"] }

          its(%w[email_address]) { should eq("bob@example.org") }
          its(%w[first_name]) { should eq("bob") }
          its(%w[last_name]) { should eq("monkhouse") }
          its(%w[organisation]) { should eq("bbc") }
          its(%w[reason]) { should eq("star qualities") }
        end

        context "with a user that does not already exist" do
          it "should create the access_request record" do
            expect(response).to have_http_status(:success)
            access_request = AccessRequest.find_by(email_address: "bob@example.org")
            expect(access_request).not_to be_nil
            expect(access_request.first_name).to eq("bob")
            expect(access_request.last_name).to eq("monkhouse")
            expect(access_request.organisation).to eq("bbc")
            expect(access_request.reason).to eq("star qualities")
            expect(access_request.request_date_utc).to be_within(1.second).of Time.now.utc # https://github.com/travisjeffery/timecop/issues/97
            expect(access_request.requester.email).to eq(requesting_user.email)
          end
        end
      end

      describe "failed validation" do
        let(:params) {
          {
            _jsonapi: {
              data: {
                attributes: {
                  email_address: "",
                  first_name: "",
                  last_name: "",
                  organisation: "",
                  reason: "",
                },
                type: "access_request",
              },
            },
          }
        }

        let(:json_data) { JSON.parse(response.body)["errors"] }

        it { should have_http_status(:unprocessable_entity) }

        it "has validation error details" do
          expect(json_data.count).to eq 5
          expect(json_data[0]["detail"]).to eq("Enter your first name")
          expect(json_data[1]["detail"]).to eq("Enter your last name")
          expect(json_data[2]["detail"]).to eq("Enter your email address")
          expect(json_data[3]["detail"]).to eq("Enter their organisation")
          expect(json_data[4]["detail"]).to eq("Why do they need access?")
        end

        it "has validation error pointers" do
          expect(json_data[0]["source"]["pointer"]).to eq("/data/attributes/first_name")
          expect(json_data[1]["source"]["pointer"]).to eq("/data/attributes/last_name")
          expect(json_data[2]["source"]["pointer"]).to eq("/data/attributes/email_address")
          expect(json_data[3]["source"]["pointer"]).to eq("/data/attributes/organisation")
          expect(json_data[4]["source"]["pointer"]).to eq("/data/attributes/reason")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:first_access_request) do
      access_request = create(:access_request)
      access_request.discard
      access_request
    end

    before do
      delete "/api/v2/access_requests/#{first_access_request.id}",
             headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    it "should add a discarded_at timestamp" do
      expect(first_access_request.discarded_at).to be_within(1.second).of(Time.now.utc)
    end
  end
end
