require "rails_helper"

RSpec.describe "/api/v2/providers/<accredited_body_code>/contacts", type: :request do
  describe "PUT #update" do
    context "with valid parameters" do
      it "returns 201" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_contacts
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_valid_parameters_are_posted
        then_the_updated_contact_is_returned
      end
    end
  end

  def given_an_accredited_body_exists
    @accredited_body = create(:provider, :accredited_body)
  end

  def given_the_accredited_body_has_contacts
    @contact = create(:contact, provider: @accredited_body)
  end

  def given_i_am_an_authenticated_user_from_the_accredited_body
    @user = create(:user)
    @user.organisations << @accredited_body.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def when_valid_parameters_are_posted
    params = {
      "_jsonapi" =>
      {
        "data" => {
          "type" => "contacts",
          "attributes" => {
            "name" => "new name",
          },
        },
      },
    }

    put "/api/v2/contacts/#{@contact.id}",
        params: params,
        headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_the_updated_contact_is_returned
    parsed_response = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(parsed_response["data"]["attributes"]["name"]).to eq("new name")
  end
end
