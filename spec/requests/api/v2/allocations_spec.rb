require "rails_helper"

RSpec.describe "/api/v2/allocations/<id>", type: :request do
  describe "GET" do
    context "when the allocation exists" do
      it "returns 200" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_an_allocation_has_been_created_by_the_accredited_body_for_the_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_get_request_to_the_endpoint
        then_the_allocation_is_returned
      end
    end

    context "when the allocation does not exist" do
      it "returns 404" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_get_request_to_the_endpoint
        then_i_receive_404_not_found
      end
    end
  end

  describe "PUT" do
    context "with valid parameters" do
      it "returns 200" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_an_allocation_has_been_created_by_the_accredited_body_for_the_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_put_request_to_the_endpoint_with_valid_parameters
        then_the_updated_allocation_is_returned
      end
    end

    context "with invalid parameters" do
      it "returns 422" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_an_allocation_has_been_created_by_the_accredited_body_for_the_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_put_request_to_the_endpoint_with_invalid_parameters
        then_i_receive_422_unprocessable
      end
    end

    context "when the allocation doesn't exist" do
      it "returns 404" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_put_request_to_the_endpoint_with_valid_parameters
        then_i_receive_404_not_found
      end
    end
  end

  describe "DELETE" do
    context "with an existing allocation" do
      it "returns 200" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_an_allocation_has_been_created_by_the_accredited_body_for_the_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_delete_request_to_the_endpoint
        then_the_allocation_is_deleted
      end
    end

    context "with an allocation that doesn't exist" do
      it "returns 404" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_make_a_delete_request_to_the_endpoint_with_an_invalid_id
        then_i_receive_404_not_found
      end
    end

    context "with a user from a different accredited body" do
      it "user unauthorized" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_an_allocation_has_been_created_by_the_accredited_body_for_the_training_provider
        given_i_am_an_authenticated_user_from_another_accredited_body
        then_an_unauthorized_error_is_raised
      end
    end
  end

  def given_an_accredited_body_exists
    @accredited_body = create(:provider, :accredited_body)
  end

  def given_the_accredited_body_has_a_training_provider
    @training_provider = create(:provider)
    @course = create(:course, provider: @training_provider, accredited_body_code: @accredited_body.provider_code)
  end

  def given_i_am_an_authenticated_user_from_the_accredited_body
    @user = create(:user)
    @user.organisations << @accredited_body.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def given_i_am_an_authenticated_user_from_another_accredited_body
    @user = create(:user)
    @another_accredited_body = create(:provider, :accredited_body)
    @user.organisations << @another_accredited_body.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def given_an_allocation_has_been_created_by_the_accredited_body_for_the_training_provider
    @allocation = create(:allocation, accredited_body_id: @accredited_body.id, provider_id: @training_provider.id, number_of_places: 10)
  end

  def when_i_make_a_get_request_to_the_endpoint
    unknown_id = 10001
    get "/api/v2/allocations/#{@allocation&.id || unknown_id}", headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_i_make_a_put_request_to_the_endpoint_with_valid_parameters
    unknown_id = 10001
    updated_number_of_places = 50

    @update_params = {
      "_jsonapi" => {
        "data" => {
          "type" => "allocations",
          "attributes" => {
            "number_of_places" => updated_number_of_places,
            "request_type" => "declined",
          },
        },
      },
    }

    put "/api/v2/allocations/#{@allocation&.id || unknown_id}",
        params: @update_params,
        headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_i_make_a_put_request_to_the_endpoint_with_invalid_parameters
    @update_params = {
      "_jsonapi" => {
        "data" => {
          "type" => "allocations",
          "attributes" => {
            "number_of_places" => "dave",
          },
        },
      },
    }

    put "/api/v2/allocations/#{@allocation.id}",
        params: @update_params,
        headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_the_allocation_is_returned
    expect(response).to have_http_status(:ok)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"]["type"]).to eq("allocations")
    expect(parsed_response["data"]["attributes"]["number_of_places"]).to eq(10)
  end

  def when_i_get_the_allocations_index_endpoint
    get "/api/v2/providers/#{@accredited_body.provider_code}/allocations?include=provider%2Caccredited_body",
        headers: { "HTTP_AUTHORIZATION" => @credentials }
    expect(parsed_response["data"]["id"]).to eq(@accredited_body.id.to_s)
  end

  def when_i_make_a_delete_request_to_the_endpoint
    delete "/api/v2/allocations/#{@allocation.id}",
           headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_i_make_a_delete_request_to_the_endpoint_with_an_invalid_id
    bad_id = 5000
    delete "/api/v2/allocations/#{bad_id}",
           headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_the_updated_allocation_is_returned
    expect(response).to have_http_status(:ok)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"]["id"]).to eq(@allocation.id.to_s)
    expect(parsed_response["data"]["number_of_places"]).to eq(@update_params.dig("_json_api", "data", "attributes", "number_of_places"))
    expect(parsed_response["data"]["request_type"]).to eq(@update_params.dig("_json_api", "data", "attributes", "request_type"))
  end

  def then_i_receive_404_not_found
    expect(response).to have_http_status(:not_found)
  end

  def then_the_allocations_from_the_current_recruitment_cycle_are_returned
    expect(response).to have_http_status(:ok)

    parsed_response = JSON.parse(response.body)

    expect(parsed_response["data"].count).to eq(1)
    expect(parsed_response["data"].first["id"]).to eq(@current_allocation.id.to_s)

    accredited_body_relationship = parsed_response["data"].first["relationships"]["accredited_body"]
    provider_relationship = parsed_response["data"].first["relationships"]["provider"]

    expect(accredited_body_relationship.count).to eq(1)
    expect(provider_relationship.count).to eq(1)
  end

  def then_i_receive_422_unprocessable
    expect(response).to have_http_status(:unprocessable_entity)
  end

  def then_the_allocation_is_deleted
    expect(response).to have_http_status(:ok)
  end

  def then_an_unauthorized_error_is_raised
    expect {
      delete "/api/v2/allocations/#{@allocation.id}",
             headers: { "HTTP_AUTHORIZATION" => @credentials }
    }.to raise_error Pundit::NotAuthorizedError
  end
end
