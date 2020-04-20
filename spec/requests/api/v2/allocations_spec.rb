require "rails_helper"

RSpec.describe "/api/v2/providers/<accredited_body_code>/allocations", type: :request do
  describe "POST" do
    context "with valid parameters" do
      it "returns 201" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_valid_parameters_are_posted_to_the_allocations_endpoint
        then_a_new_allocation_is_returned
      end
    end

    context "with invalid parameters" do
      it "returns 422 with errors" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_a_training_provider
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_invalid_parameters_are_posted_to_the_allocations_endpoint
        then_the_allocation_errors_are_returned
      end
    end
  end

  describe "GET" do
    it "returns the allocations for the accredited body from the current recruitment cycle" do
      given_an_accredited_body_exists
      given_the_accredited_body_has_a_training_provider
      given_the_accredited_body_has_allocations_for_the_current_recruitment_cycle
      given_the_accredited_body_has_allocations_from_the_previous_recruitment_cycle
      given_i_am_an_authenticated_user_from_the_accredited_body
      when_i_get_the_allocations_index_endpoint
      then_the_allocations_from_the_current_recruitment_cycle_are_returned
    end
  end

  def given_an_accredited_body_exists
    @accredited_body = create(:provider, :accredited_body)
  end

  def given_the_accredited_body_has_a_training_provider
    @training_provider = create(:provider)
    @course = create(:course, provider: @training_provider, accrediting_provider_code: @accredited_body.provider_code)
  end

  def given_i_am_an_authenticated_user_from_the_accredited_body
    @user = create(:user)
    @user.organisations << @accredited_body.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def given_the_accredited_body_has_allocations_for_the_current_recruitment_cycle
    @current_allocation = create(:allocation, accredited_body_id: @accredited_body.id, provider_id: @training_provider.id, number_of_places: 10)
  end

  def given_the_accredited_body_has_allocations_from_the_previous_recruitment_cycle
    previous_accredited_body = create(:provider, :previous_recruitment_cycle, :accredited_body, provider_code: @accredited_body.provider_code)
    previous_training_provider = create(:provider, :previous_recruitment_cycle, provider_code: @training_provider.provider_code)
    @previous_allocation = create(:allocation, accredited_body_id: previous_accredited_body.id, provider_id: previous_training_provider.id, number_of_places: 10)
  end

  def when_valid_parameters_are_posted_to_the_allocations_endpoint
    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations", params: { allocation: { provider_id: @training_provider.id } }, headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_invalid_parameters_are_posted_to_the_allocations_endpoint
    invalid_provider_id = 0
    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations", params: { allocation: { provider_id: invalid_provider_id } }, headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_i_get_the_allocations_index_endpoint
    get "/api/v2/providers/#{@accredited_body.provider_code}/allocations", headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_a_new_allocation_is_returned
    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"]["type"]).to eq("allocations")
  end

  def then_the_allocation_errors_are_returned
    expect(response).to have_http_status(:unprocessable_entity)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["errors"]).to be_present
  end

  def then_the_allocations_from_the_current_recruitment_cycle_are_returned
    expect(response).to have_http_status(:ok)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"].count).to eq(1)
    expect(parsed_response["data"].first["id"]).to eq(@current_allocation.id.to_s)
  end
end
