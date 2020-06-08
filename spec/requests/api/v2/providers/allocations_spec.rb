require "rails_helper"

RSpec.describe "/api/v2/providers/<accredited_body_code>/allocations", type: :request do
  describe "POST #create" do
    context "with valid parameters" do
      context "when no number_of_places specified" do
        it "returns 201" do
          given_an_accredited_body_exists
          given_the_accredited_body_has_a_training_provider
          given_i_am_an_authenticated_user_from_the_accredited_body
          given_there_is_a_previous_allocation
          when_valid_parameters_are_posted_with_unspecified_number_of_places
          then_a_new_allocation_is_returned_with_backfilled_number_of_places
        end
      end

      context "when zero number_of_places specified" do
        it "returns 201" do
          given_an_accredited_body_exists
          given_the_accredited_body_has_a_training_provider
          given_i_am_an_authenticated_user_from_the_accredited_body
          when_valid_parameters_are_posted_with_zero_number_of_places
          then_a_new_allocation_is_returned_with_zero_number_of_places
        end
      end

      context "when the request_type is specified" do
        it "returns 201" do
          given_an_accredited_body_exists
          given_the_accredited_body_has_a_training_provider
          given_i_am_an_authenticated_user_from_the_accredited_body
          when_valid_parameters_are_posted_with_request_type
          then_a_new_allocation_is_returned_with_the_request_type
        end
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

  describe "GET #index" do
    it "returns the allocations for the accredited body from the current recruitment cycle" do
      given_an_accredited_body_exists
      given_the_accredited_body_has_a_training_provider
      given_the_accredited_body_has_allocations_for_the_current_recruitment_cycle
      given_the_accredited_body_has_allocations_from_the_previous_recruitment_cycle
      given_i_am_an_authenticated_user_from_the_accredited_body
      when_i_get_the_allocations_index_endpoint
      then_the_allocations_from_the_current_recruitment_cycle_are_returned
    end

    context "with filter" do
      it "returns filtered allocations" do
        given_an_accredited_body_exists
        given_the_accredited_body_has_multiple_training_providers
        given_the_accredited_body_has_allocations_for_the_current_recruitment_cycle
        given_the_accredited_body_has_allocations_from_the_previous_recruitment_cycle
        given_i_am_an_authenticated_user_from_the_accredited_body
        when_i_get_the_filtered_allocations_index_endpoint
        then_the_filtered_allocations_from_the_current_recruitment_cycle_are_returned
      end
    end
  end

  def given_an_accredited_body_exists
    @accredited_body = create(:provider, :accredited_body)
  end

  def given_the_accredited_body_has_a_training_provider
    @training_providers = [create(:provider)]
    create(:course, provider: @training_providers.first, accredited_body_code: @accredited_body.provider_code)
  end

  def given_the_accredited_body_has_multiple_training_providers
    @training_providers = 2.times.map do
      training_provider = create(:provider)
      create(:course, provider: training_provider, accredited_body_code: @accredited_body.provider_code)

      training_provider
    end
  end

  def given_i_am_an_authenticated_user_from_the_accredited_body
    @user = create(:user)
    @user.organisations << @accredited_body.organisation
    payload = { email: @user.email }
    token = JWT.encode payload, Settings.authentication.secret, Settings.authentication.algorithm

    @credentials = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def when_valid_parameters_are_posted_with_unspecified_number_of_places
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "allocations",
          "attributes" => {
            "provider_id" => @training_providers.first.id.to_s,
          },
        },
      },
    }

    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations",
         params: params,
         headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_valid_parameters_are_posted_with_zero_number_of_places
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "allocations",
          "attributes" => {
            "provider_id" => @training_providers.first.id.to_s,
            number_of_places: 0,
          },
        },
      },
    }

    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations",
         params: params,
         headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_valid_parameters_are_posted_with_request_type
    params = {
      "_jsonapi" => {
        "data" => {
          "type" => "allocations",
          "attributes" => {
            "provider_id" => @training_providers.first.id.to_s,
            "request_type" => "declined",
          },
        },
      },
    }

    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations",
         params: params,
         headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def given_the_accredited_body_has_allocations_for_the_current_recruitment_cycle
    @current_allocations = @training_providers.map do |training_provider|
      create(
        :allocation,
        accredited_body: @accredited_body,
        provider: training_provider,
        number_of_places: 10,
        recruitment_cycle: RecruitmentCycle.current,
      )
    end
  end

  def given_the_accredited_body_has_allocations_from_the_previous_recruitment_cycle
    previous_accredited_body = create(:provider, :previous_recruitment_cycle, :accredited_body, provider_code: @accredited_body.provider_code)
    previous_training_provider = create(:provider, :previous_recruitment_cycle, provider_code: @training_providers.first.provider_code)
    @previous_allocation = create(
      :allocation,
      accredited_body_id: previous_accredited_body.id,
      provider_id: previous_training_provider.id,
      number_of_places: 10,
      recruitment_cycle: previous_recruitment_cycle,
      accredited_body_code: previous_accredited_body.provider_code,
      provider_code: previous_training_provider.provider_code,
    )
  end

  def when_valid_parameters_are_posted_to_the_allocations_endpoint
    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations", params: { allocation: { provider_id: @training_providers.first.id } }, headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_invalid_parameters_are_posted_to_the_allocations_endpoint
    invalid_provider_id = 0
    post "/api/v2/providers/#{@accredited_body.provider_code}/allocations", params: { allocation: { provider_id: invalid_provider_id } }, headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def previous_number_of_places
    @previous_number_of_places ||= rand(1..99)
  end

  def previous_recruitment_cycle
    create(:recruitment_cycle, year: RecruitmentCycle.current.year.to_i - 1)
  end

  def given_there_is_a_previous_allocation
    create(
      :allocation,
      provider_id: @training_providers.first.id,
      accredited_body_id: @accredited_body.id,
      number_of_places: previous_number_of_places,
      recruitment_cycle: previous_recruitment_cycle,
      provider_code: @training_providers.first.provider_code,
      accredited_body_code: @accredited_body.provider_code,
    )
  end

  def then_a_new_allocation_is_returned_with_backfilled_number_of_places
    allocation = Allocation.last
    expect(allocation.accredited_body_code).to eql(@accredited_body.provider_code)
    expect(allocation.provider_code).to eql(@training_providers.first.provider_code)
    expect(allocation.recruitment_cycle_id).to eql(RecruitmentCycle.current_recruitment_cycle.id)

    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"]["type"]).to eq("allocations")
    expect(parsed_response["data"]["attributes"]["number_of_places"]).to eq(previous_number_of_places)
    expect(parsed_response["data"]["attributes"]["request_type"]).to eq("repeat")
  end

  def when_i_get_the_allocations_index_endpoint
    get "/api/v2/providers/#{@accredited_body.provider_code}/allocations", headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def when_i_get_the_filtered_allocations_index_endpoint
    provider_to_filter = @training_providers.first
    get "/api/v2/providers/#{@accredited_body.provider_code}/allocations?filter[training_provider_code]=#{provider_to_filter.provider_code}", headers: { "HTTP_AUTHORIZATION" => @credentials }
  end

  def then_a_new_allocation_is_returned_with_zero_number_of_places
    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"]["type"]).to eq("allocations")
    expect(parsed_response["data"]["attributes"]["number_of_places"]).to eq(0)
    expect(parsed_response["data"]["attributes"]["request_type"]).to eq("declined")
  end

  def then_the_allocation_errors_are_returned
    expect(response).to have_http_status(:unprocessable_entity)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["errors"]).to be_present
  end

  def then_the_allocations_from_the_current_recruitment_cycle_are_returned
    expect(response).to have_http_status(:ok)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"].count).to eq(@training_providers.size)
    expect(parsed_response["data"].first["id"]).to eq(@current_allocations.first.id.to_s)
  end

  def then_the_filtered_allocations_from_the_current_recruitment_cycle_are_returned
    expect(response).to have_http_status(:ok)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"].count).to eq(1)
    expect(parsed_response["data"].first["id"]).to eq(@current_allocations.first.id.to_s)
  end

  def then_a_new_allocation_is_returned_with_the_request_type
    expect(response).to have_http_status(:created)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["data"]["type"]).to eq("allocations")
    expect(parsed_response["data"]["attributes"]["number_of_places"]).to eq(0)
    expect(parsed_response["data"]["attributes"]["request_type"]).to eq("declined")
  end
end
