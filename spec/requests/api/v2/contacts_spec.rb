require "rails_helper"

RSpec.describe "/api/v2/contacts", type: :request do
  describe "GET #show" do
    context "with valid contact id" do
      it "returns a 200" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_contacts
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_get_request_to_the_endpoint
        then_the_contact_is_returned
      end
    end

    context "with invalid contact id" do
      it "returns a 404" do
        given_an_accredited_body_exists
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_get_request_to_the_endpoint
        then_i_receive_404_not_found
      end
    end
  end

  describe "PUT #update" do
    context "with valid parameters" do
      it "returns a 201" do
        params = { name: "new name" }

        given_an_accredited_body_exists
        given_the_accredited_body_has_contacts
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_parameters_are_posted(params)
        then_the_updated_contact_is_returned
      end
    end

    context "with invalid parameters" do
      it "returns a 422" do
        params = { name: nil }

        given_an_accredited_body_exists
        given_the_accredited_body_has_contacts
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_parameters_are_posted(params)
        then_the_response_returns_errors
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
    @user.providers << @accredited_body
    payload = { email: @user.email }
    @credentials = encode_to_credentials(payload)
  end

  def when_parameters_are_posted(params)
    params = {
      "_jsonapi" =>
      {
        "data" => {
          "type" => "contacts",
          "attributes" => params.as_json,
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

  def then_the_response_returns_errors
    parsed_response = JSON.parse(response.body)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(parsed_response["errors"]).to be_present
  end

  def when_i_make_a_get_request_to_the_endpoint
    unknown_id = 10_001
    get "/api/v2/contacts/#{@contact&.id || unknown_id}", headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_the_contact_is_returned
    parsed_response = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(parsed_response["data"]["id"].to_i).to eq(@contact.id)
    expect(parsed_response["data"]["type"]).to eq("contacts")
  end

  def then_i_receive_404_not_found
    expect(response).to have_http_status(:not_found)
  end
end
