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

  def when_valid_parameters_are_posted_to_the_allocations_endpoint
    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations", params: { allocation: { provider_id: @training_provider.id } }, headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_invalid_parameters_are_posted_to_the_allocations_endpoint
    invalid_provider_id = 0
    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations", params: { allocation: { provider_id: invalid_provider_id } }, headers: { "HTTP_AUTHORIZATION" => @credentials }
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
end
